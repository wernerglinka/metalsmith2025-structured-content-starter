/**
 * @fileoverview Unit tests for the component installer: the pure logic (the
 * not-installed catalog diff, dependency-closure resolution, argument parsing,
 * commit message shape, porcelain parsing) and the git recording, exercised
 * against a scratch repository in a temporary directory.
 */

import { strict as assert } from 'node:assert';
import { execFile } from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { after, before, describe, it } from 'node:test';
import { promisify } from 'node:util';
import {
  availableNotInstalled,
  changedPaths,
  commitMessage,
  componentPath,
  createGit,
  parseArguments,
  resolveClosure
} from '../scripts/install-components.mjs';

const run = promisify(execFile);

const catalog = {
  sections: [
    { name: 'banner', type: 'section', requires: ['ctas', 'text', 'commons'] },
    { name: 'hero', type: 'section', requires: ['text', 'commons'] }
  ],
  partials: [
    { name: 'ctas', type: 'partial', requires: ['button', 'text-link'] },
    { name: 'text', type: 'partial', requires: [] },
    { name: 'button', type: 'partial', requires: [] },
    { name: 'text-link', type: 'partial', requires: [] },
    { name: 'commons', type: 'section', requires: [] }
  ]
};
const byName = new Map([...catalog.sections, ...catalog.partials].map((entry) => [entry.name, entry]));

describe('install-components pure logic', () => {
  describe('availableNotInstalled', () => {
    it('lists catalog entries that are not installed, sections first', () => {
      const installed = new Set(['text', 'commons']);
      const names = availableNotInstalled(catalog, installed).map((entry) => entry.name);
      assert.deepEqual(names, ['banner', 'hero', 'ctas', 'button', 'text-link']);
    });

    it('returns nothing when everything is installed', () => {
      const installed = new Set(['banner', 'hero', 'ctas', 'text', 'button', 'text-link', 'commons']);
      assert.deepEqual(availableNotInstalled(catalog, installed), []);
    });
  });

  describe('resolveClosure', () => {
    it('orders dependencies before dependents and skips installed', () => {
      const installed = new Set(['text', 'commons']);
      const order = resolveClosure(['banner'], byName, installed).map((entry) => entry.name);
      assert.deepEqual(order, ['button', 'text-link', 'ctas', 'banner']);
    });

    it('does not duplicate a dependency shared by two selections', () => {
      const order = resolveClosure(['banner', 'hero'], byName, new Set()).map((entry) => entry.name);
      assert.equal(order.filter((name) => name === 'text').length, 1);
      assert.equal(order.filter((name) => name === 'commons').length, 1);
      assert.ok(order.indexOf('text') < order.indexOf('hero'));
    });

    it('throws on a name absent from the catalog', () => {
      assert.throws(() => resolveClosure(['nope'], byName, new Set()), /not in the canonical catalog/);
    });

    it('reinstalls a named component when it is excluded from the installed set', () => {
      // How the installer pulls a canon update: the chosen name is dropped from
      // the installed set, its dependencies are not.
      const installed = new Set(['banner', 'ctas', 'text', 'button', 'text-link', 'commons']);
      const forClosure = new Set([...installed].filter((name) => name !== 'banner'));
      const order = resolveClosure(['banner'], byName, forClosure).map((entry) => entry.name);
      assert.deepEqual(order, ['banner']);
    });
  });

  describe('parseArguments', () => {
    it('separates names from flags', () => {
      const parsed = parseArguments(['hero', '--force', 'banner']);
      assert.deepEqual(parsed.names, ['hero', 'banner']);
      assert.equal(parsed.force, true);
      assert.equal(parsed.noCommit, false);
    });

    it('reads --no-commit', () => {
      const parsed = parseArguments(['--no-commit']);
      assert.deepEqual(parsed.names, []);
      assert.equal(parsed.noCommit, true);
    });
  });

  describe('componentPath', () => {
    const config = { componentsBasePath: 'lib/layouts/components', sectionsDir: 'sections', partialsDir: '_partials' };

    it('places sections and partials in their own directories', () => {
      assert.equal(componentPath({ name: 'hero', type: 'section' }, config), 'lib/layouts/components/sections/hero');
      assert.equal(componentPath({ name: 'ctas', type: 'partial' }, config), 'lib/layouts/components/_partials/ctas');
    });
  });

  describe('commitMessage', () => {
    it('carries name, version and content hash as trailers', () => {
      const message = commitMessage(
        { name: 'hero', version: '1.2.0', contentHash: 'a3f9c2e17b40d8e6' },
        'nunjucks-components.com'
      );
      assert.equal(
        message,
        'component: install hero@1.2.0 from nunjucks-components.com\n\n' +
          'Component-Name: hero\nComponent-Version: 1.2.0\nContent-Hash: a3f9c2e17b40d8e6\n'
      );
    });

    it('is findable by the name trailer alone', () => {
      const message = commitMessage({ name: 'hero', version: '1.2.0' }, 'example.com');
      assert.match(message, /^Component-Name: hero$/m);
    });

    it('omits trailers the catalog entry does not carry', () => {
      const message = commitMessage({ name: 'hero' }, 'example.com');
      assert.equal(message, 'component: install hero from example.com\n\nComponent-Name: hero\n');
    });
  });

  describe('changedPaths', () => {
    it('reads staged, unstaged and untracked entries', () => {
      const porcelain = ' M lib/a.css\nA  lib/b.css\n?? lib/c/\n';
      assert.deepEqual(changedPaths(porcelain), ['lib/a.css', 'lib/b.css', 'lib/c/']);
    });

    it('reports the destination of a rename', () => {
      assert.deepEqual(changedPaths('R  lib/old.css -> lib/new.css\n'), ['lib/new.css']);
    });

    it('is empty for a clean tree', () => {
      assert.deepEqual(changedPaths(''), []);
    });
  });
});

describe('install recording in git', () => {
  let repository;
  const config = { componentsBasePath: 'lib/layouts/components', sectionsDir: 'sections', partialsDir: '_partials' };
  const heroPath = componentPath({ name: 'hero', type: 'section' }, config);

  /**
   * Write a file inside the scratch repository, creating parents as needed.
   * @param {string} relative - Repo-relative path
   * @param {string} contents - File contents
   * @returns {Promise<void>} Resolves when written
   */
  const write = async (relative, contents) => {
    const target = path.join(repository, relative);
    await fs.mkdir(path.dirname(target), { recursive: true });
    await fs.writeFile(target, contents);
  };

  before(async () => {
    repository = await fs.mkdtemp(path.join(os.tmpdir(), 'install-components-'));
    await run('git', ['init', '-b', 'main'], { cwd: repository });
    await run('git', ['config', 'user.email', 'test@example.com'], { cwd: repository });
    await run('git', ['config', 'user.name', 'Test'], { cwd: repository });
    // The scratch repo must not inherit a global signing setup it cannot satisfy.
    await run('git', ['config', 'commit.gpgsign', 'false'], { cwd: repository });
    await write('README.md', 'scratch\n');
    await run('git', ['add', '.'], { cwd: repository });
    await run('git', ['commit', '--message', 'initial'], { cwd: repository });
  });

  after(async () => {
    await fs.rm(repository, { recursive: true, force: true });
  });

  it('recognizes a work tree', async () => {
    assert.equal(await createGit(repository, run).isRepository(), true);
  });

  it('does not recognize a plain directory', async () => {
    const plain = await fs.mkdtemp(path.join(os.tmpdir(), 'not-a-repo-'));
    try {
      assert.equal(await createGit(plain, run).isRepository(), false);
    } finally {
      await fs.rm(plain, { recursive: true, force: true });
    }
  });

  it('sees nothing under a component path that was never installed', async () => {
    assert.deepEqual(await createGit(repository, run).changedUnder([heroPath]), []);
  });

  it('commits one component on its own, with its trailers', async () => {
    const git = createGit(repository, run);
    await write(`${heroPath}/hero.njk`, '<section class="hero"></section>\n');
    await write(`${heroPath}/hero.css`, '.hero { display: grid; }\n');

    await git.recordInstall(
      heroPath,
      commitMessage({ name: 'hero', version: '1.2.0', contentHash: 'abc123' }, 'example.com')
    );

    const { stdout: message } = await run('git', ['log', '-1', '--pretty=%B'], { cwd: repository });
    assert.match(message, /^component: install hero@1\.2\.0 from example\.com$/m);
    assert.match(message, /^Component-Name: hero$/m);
    assert.match(message, /^Content-Hash: abc123$/m);

    const { stdout: files } = await run('git', ['show', '--name-only', '--pretty=format:', 'HEAD'], {
      cwd: repository
    });
    assert.deepEqual(files.trim().split('\n').sort(), [`${heroPath}/hero.css`, `${heroPath}/hero.njk`]);
  });

  it('records nothing when a reinstall changed no bytes', async () => {
    const git = createGit(repository, run);
    const { stdout: before } = await run('git', ['rev-parse', 'HEAD'], { cwd: repository });

    const committed = await git.recordInstall(
      heroPath,
      commitMessage({ name: 'hero', version: '1.2.0' }, 'example.com')
    );

    const { stdout: after } = await run('git', ['rev-parse', 'HEAD'], { cwd: repository });
    assert.equal(committed, false);
    assert.equal(after.trim(), before.trim());
  });

  it('is findable by its name trailer', async () => {
    const { stdout } = await run('git', ['log', '--grep=Component-Name: hero', '--pretty=%s'], { cwd: repository });
    assert.match(stdout, /component: install hero/);
  });

  it('leaves unrelated staged work in the index rather than sweeping it into the commit', async () => {
    const git = createGit(repository, run);
    await write('src/index.md', 'work in progress\n');
    await run('git', ['add', 'src/index.md'], { cwd: repository });

    const ctasPath = componentPath({ name: 'ctas', type: 'partial' }, config);
    await write(`${ctasPath}/ctas.njk`, '<div class="ctas"></div>\n');
    await git.recordInstall(ctasPath, commitMessage({ name: 'ctas', version: '2.0.0' }, 'example.com'));

    const { stdout: files } = await run('git', ['show', '--name-only', '--pretty=format:', 'HEAD'], {
      cwd: repository
    });
    assert.deepEqual(files.trim().split('\n'), [`${ctasPath}/ctas.njk`]);

    const { stdout: staged } = await run('git', ['diff', '--cached', '--name-only'], { cwd: repository });
    assert.equal(staged.trim(), 'src/index.md');
  });

  it('reports a locally edited component as changed, which is what the preflight refuses on', async () => {
    const git = createGit(repository, run);
    await write(`${heroPath}/hero.css`, '.hero { display: flex; }\n');
    assert.deepEqual(await git.changedUnder([heroPath]), [`${heroPath}/hero.css`]);
  });
});
