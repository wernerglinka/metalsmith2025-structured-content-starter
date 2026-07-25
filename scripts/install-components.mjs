/* eslint-disable no-console */

/**
 * Interactive component installer.
 *
 * Pulls components from the canonical nunjucks-components published downloads,
 * shows which ones are not yet installed in this site, lets the developer pick,
 * resolves their dependency closure, downloads the archives, and unzips them
 * into place. The source is always the canonical truth, never a local copy.
 *
 * Every install is recorded in git as its own commit, one per component, so
 * what landed and at which version is answerable from history and what you
 * changed since is one diff away:
 *
 *   git log --grep="Component-Name: hero" -1
 *   git diff <that commit> HEAD -- lib/layouts/components/sections/hero
 *
 * Usage:
 *   npm run components                              # interactive: pick from the not-installed list
 *   node scripts/install-components.mjs <name...>   # install named components plus their dependencies
 *   node scripts/install-components.mjs --force     # install even if component paths are dirty
 *   node scripts/install-components.mjs --no-commit # place files only, record nothing
 *
 * --force is the only way past the dirty-path refusal; --no-commit turns off
 * recording but keeps that guard, since it protects the files, not the history.
 *
 * A component named on the command line is reinstalled even when it is already
 * present, which is how you pull a canon update; dependencies are only fetched
 * when missing. The interactive list only offers what is not installed.
 *
 * Config (`nunjucks-components.config.json` at the project root):
 *   registry           - canonical site origin, e.g. "https://nunjucks-components.com"
 *   componentsBasePath - e.g. "lib/layouts/components"
 *   sectionsDir        - e.g. "sections"
 *   partialsDir        - e.g. "_partials"
 */

import { execFile } from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { stdin, stdout } from 'node:process';
import readline from 'node:readline/promises';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';

const runCommand = promisify(execFile);
const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(scriptDirectory, '..');

/**
 * Split the command line into component names and flags.
 * @param {string[]} argv - Arguments after the script name
 * @returns {{names: string[], force: boolean, noCommit: boolean}} Parsed arguments
 */
export const parseArguments = (argv) => ({
  names: argv.filter((argument) => !argument.startsWith('--')),
  force: argv.includes('--force'),
  noCommit: argv.includes('--no-commit')
});

/**
 * Read and validate the project config.
 * @param {string} root - Project root directory
 * @returns {Promise<{registry: string, componentsBasePath: string, sectionsDir: string, partialsDir: string}>} Parsed config
 */
const loadConfig = async (root) => {
  const raw = await fs.readFile(path.join(root, 'nunjucks-components.config.json'), 'utf8');
  const config = JSON.parse(raw);
  if (!config.registry) {
    throw new Error(
      'nunjucks-components.config.json is missing "registry" (the canonical site origin, e.g. https://nunjucks-components.com)'
    );
  }
  return config;
};

/**
 * Fetch the canonical catalog and index every component by name.
 * @param {string} registry - Canonical site origin
 * @returns {Promise<{sections: object[], partials: object[], byName: Map<string, object>}>} Catalog
 */
const fetchCatalog = async (registry) => {
  const url = `${registry.replace(/\/$/, '')}/downloads/manifest.json`;
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Could not fetch catalog at ${url} (${response.status})`);
  }
  const manifest = await response.json();
  const sections = manifest.sections || [];
  const partials = manifest.partials || [];
  const byName = new Map();
  [...sections, ...partials].forEach((entry) => {
    byName.set(entry.name, entry);
  });
  return { sections, partials, byName };
};

/**
 * List the component names already present in the site, across sections and partials.
 * @param {string} root - Project root
 * @param {object} config - Project config
 * @returns {Promise<Set<string>>} Installed component names
 */
const listInstalled = async (root, config) => {
  const installed = new Set();
  const directories = [
    path.join(root, config.componentsBasePath, config.sectionsDir),
    path.join(root, config.componentsBasePath, config.partialsDir)
  ];
  for (const directory of directories) {
    let entries = [];
    try {
      entries = await fs.readdir(directory, { withFileTypes: true });
    } catch {
      // Directory may not exist yet; treat as nothing installed there.
    }
    entries
      .filter((entry) => entry.isDirectory())
      .forEach((entry) => {
        installed.add(entry.name);
      });
  }
  return installed;
};

/**
 * Catalog entries that are not yet installed, sections listed before partials.
 * @param {{sections: object[], partials: object[]}} catalog - Catalog
 * @param {Set<string>} installed - Installed names
 * @returns {object[]} Available-but-not-installed entries
 */
export const availableNotInstalled = (catalog, installed) =>
  [...catalog.sections, ...catalog.partials].filter((entry) => !installed.has(entry.name));

/**
 * Resolve the full set to install: the chosen components plus every required
 * dependency not already installed, with dependencies ordered before dependents.
 * @param {string[]} chosen - Selected component names
 * @param {Map<string, object>} byName - Catalog indexed by name
 * @param {Set<string>} installed - Already installed names
 * @returns {object[]} Ordered list of catalog entries to install
 */
export const resolveClosure = (chosen, byName, installed) => {
  const ordered = [];
  const seen = new Set();
  const visit = (name) => {
    if (seen.has(name) || installed.has(name)) {
      return;
    }
    seen.add(name);
    const entry = byName.get(name);
    if (!entry) {
      throw new Error(`"${name}" is not in the canonical catalog`);
    }
    (entry.requires || []).forEach(visit);
    ordered.push(entry);
  };
  chosen.forEach(visit);
  return ordered;
};

/**
 * The repo-relative directory a component lands in.
 * @param {object} entry - Catalog entry (name, type)
 * @param {object} config - Project config
 * @returns {string} Repo-relative path, POSIX separators
 */
export const componentPath = (entry, config) => {
  const subDirectory = entry.type === 'section' ? config.sectionsDir : config.partialsDir;
  return `${config.componentsBasePath}/${subDirectory}/${entry.name}`;
};

/**
 * The commit message recording one install. The trailers are what makes an
 * install commit mechanically findable later, without any sidecar file:
 * `git log --grep="Component-Name: hero"`.
 *
 * `version` is the catalog's, which is the library's release version rather
 * than a per-component one: components are published as a set, so it records
 * which release this copy came from. `contentHash` is the per-component
 * identity and is what moves when the component's own content changes.
 *
 * @param {object} entry - Catalog entry (name, version, contentHash)
 * @param {string} source - Where the component came from, e.g. the registry host
 * @returns {string} Commit message
 */
export const commitMessage = (entry, source) => {
  const versionSuffix = entry.version ? `@${entry.version}` : '';
  const trailers = [`Component-Name: ${entry.name}`];
  if (entry.version) {
    trailers.push(`Component-Version: ${entry.version}`);
  }
  if (entry.contentHash) {
    trailers.push(`Content-Hash: ${entry.contentHash}`);
  }
  return `component: install ${entry.name}${versionSuffix} from ${source}\n\n${trailers.join('\n')}\n`;
};

/**
 * Paths reported as changed by `git status --porcelain`, staged or not.
 * @param {string} porcelain - Output of `git status --porcelain`
 * @returns {string[]} Changed paths
 */
export const changedPaths = (porcelain) =>
  porcelain
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const withoutStatus = line.slice(line.indexOf(' ') + 1).trim();
      // Renames are reported as "old -> new"; the destination is what matters.
      const arrow = withoutStatus.indexOf(' -> ');
      return arrow === -1 ? withoutStatus : withoutStatus.slice(arrow + 4);
    });

/**
 * Git operations, with the command runner injected so tests can drive them
 * against a scratch repository (or replace them entirely).
 * @param {string} root - Project root
 * @param {Function} [run=runCommand] - execFile-style runner returning {stdout}
 * @returns {{isRepository: Function, changedUnder: Function, recordInstall: Function}} Git helpers
 */
export const createGit = (root, run = runCommand) => {
  const git = (args) => run('git', args, { cwd: root });

  return {
    /**
     * Whether the project root is inside a git work tree.
     * @returns {Promise<boolean>} True when git can record installs
     */
    isRepository: async () => {
      try {
        const { stdout } = await git(['rev-parse', '--is-inside-work-tree']);
        return stdout.trim() === 'true';
      } catch {
        return false;
      }
    },

    /**
     * Paths with staged or unstaged changes under the given directories.
     * @param {string[]} paths - Repo-relative paths to check
     * @returns {Promise<string[]>} Changed paths
     */
    changedUnder: async (paths) => {
      if (!paths.length) {
        return [];
      }
      const { stdout } = await git(['status', '--porcelain', '--', ...paths]);
      return changedPaths(stdout);
    },

    /**
     * The full message of a component's most recent install commit, found by
     * its Component-Name trailer. This is how a later read gets at what canon
     * looked like when the component was installed.
     *
     * @param {string} componentName - Component to look up
     * @returns {Promise<string|null>} The commit message, or null when never installed
     */
    lastInstallMessage: async (componentName) => {
      try {
        const { stdout } = await git(['log', '--grep', `Component-Name: ${componentName}$`, '-1', '--pretty=%B']);
        return stdout.trim() || null;
      } catch {
        return null;
      }
    },

    /**
     * Stage one component's directory and commit it on its own, leaving any
     * unrelated staged work in the index untouched. A reinstall that changed
     * nothing records nothing; there is no empty commit to explain later.
     * @param {string} componentDirectory - Repo-relative component path
     * @param {string} message - Commit message
     * @returns {Promise<boolean>} True when a commit was made
     */
    recordInstall: async (componentDirectory, message) => {
      await git(['add', '--', componentDirectory]);
      const { stdout } = await git(['diff', '--cached', '--name-only', '--', componentDirectory]);
      if (!stdout.trim()) {
        return false;
      }
      await git(['commit', '--only', '--message', message, '--', componentDirectory]);
      return true;
    }
  };
};

/**
 * Download one component archive and unzip it into its target directory.
 * The archive carries a top-level `${name}/` directory, so extracting into the
 * sections or partials directory lands the component folder in place.
 * @param {object} entry - Catalog entry (name, type, downloadUrl)
 * @param {string} registry - Canonical site origin
 * @param {string} root - Project root
 * @param {object} config - Project config
 * @returns {Promise<void>} Resolves when placed
 */
const downloadAndPlace = async (entry, registry, root, config) => {
  const archiveUrl = `${registry.replace(/\/$/, '')}${entry.downloadUrl}`;
  const response = await fetch(archiveUrl);
  if (!response.ok) {
    throw new Error(`Could not download ${entry.name} at ${archiveUrl} (${response.status})`);
  }
  const buffer = Buffer.from(await response.arrayBuffer());
  const temporaryZip = path.join(os.tmpdir(), `${entry.name}-${Date.now()}.zip`);
  await fs.writeFile(temporaryZip, buffer);

  const subDirectory = entry.type === 'section' ? config.sectionsDir : config.partialsDir;
  const targetParent = path.join(root, config.componentsBasePath, subDirectory);
  await fs.mkdir(targetParent, { recursive: true });

  try {
    await runCommand('unzip', ['-o', '-q', temporaryZip, '-d', targetParent]);
  } finally {
    await fs.rm(temporaryZip, { force: true });
  }
};

/**
 * Ask the developer which not-installed components to add. Accepts list numbers
 * or names, comma-separated.
 * @param {object[]} items - Available entries
 * @returns {Promise<string[]>} Chosen names
 */
const promptSelection = async (items) => {
  const rl = readline.createInterface({ input: stdin, output: stdout });
  try {
    console.log('\nComponents available to install:\n');
    items.forEach((entry, index) => {
      const dependencies = (entry.requires || []).length ? `  (requires: ${entry.requires.join(', ')})` : '';
      console.log(`  ${String(index + 1).padStart(2)}. ${entry.name} [${entry.type}]${dependencies}`);
    });
    const answer = await rl.question('\nEnter numbers or names to install (comma-separated), or blank to cancel: ');
    const tokens = answer
      .split(',')
      .map((token) => token.trim())
      .filter(Boolean);
    return tokens.map((token) => {
      const asIndex = Number(token);
      if (Number.isInteger(asIndex) && asIndex >= 1 && asIndex <= items.length) {
        return items[asIndex - 1].name;
      }
      return token;
    });
  } finally {
    rl.close();
  }
};

/**
 * The component names to install: the ones named on the command line, or the
 * ones picked from the not-installed list when there were none.
 * @param {string[]} namesFromCli - Names passed as arguments
 * @param {object} catalog - Canonical catalog
 * @param {Set<string>} installed - Already installed names
 * @returns {Promise<string[]>} Chosen names, empty when there is nothing to do
 */
const chooseComponents = async (namesFromCli, catalog, installed) => {
  if (namesFromCli.length) {
    return namesFromCli;
  }
  const available = availableNotInstalled(catalog, installed);
  if (!available.length) {
    console.log('Every catalog component is already installed.');
    return [];
  }
  return promptSelection(available);
};

/**
 * Refuse the install when it would overwrite uncommitted work.
 * @param {object} git - Git helpers
 * @param {string[]} targets - Repo-relative component paths about to be written
 * @returns {Promise<void>} Resolves when the paths are clean
 * @throws {Error} When any target path has staged or unstaged changes
 */
const assertPathsClean = async (git, targets) => {
  const dirty = await git.changedUnder(targets);
  if (dirty.length) {
    throw new Error(
      `Uncommitted changes in component paths this install would overwrite:\n  ${dirty.join('\n  ')}\n` +
        'Commit or stash them first, or re-run with --force.'
    );
  }
};

/**
 * Place each component and, when recording, commit it on its own.
 * @param {object[]} toInstall - Ordered catalog entries, dependencies first
 * @param {object} options - Install context
 * @param {object} options.config - Project config
 * @param {object} options.git - Git helpers
 * @param {boolean} options.recording - Whether to commit each install
 * @returns {Promise<void>} Resolves when everything is placed
 */
const installAll = async (toInstall, { config, git, recording }) => {
  const source = new URL(config.registry).host;

  console.log(`\nInstalling ${toInstall.length} component(s): ${toInstall.map((entry) => entry.name).join(', ')}\n`);
  for (const entry of toInstall) {
    await downloadAndPlace(entry, config.registry, projectRoot, config);
    const recorded = recording
      ? await git.recordInstall(componentPath(entry, config), commitMessage(entry, source))
      : false;
    const version = entry.version ? `@${entry.version}` : '';
    const note = recording ? (recorded ? ' (committed)' : ' (unchanged)') : '';
    console.log(`  + ${entry.name}${version} [${entry.type}]${note}`);
  }
  console.log('\nDone. Review the added components, then build to bundle them.');
};

/**
 * Entry point. Interactive when run with no arguments; otherwise installs the
 * named components and their dependencies.
 * @returns {Promise<void>} Resolves when done
 */
const main = async () => {
  const { names: namesFromCli, force, noCommit } = parseArguments(process.argv.slice(2));
  const config = await loadConfig(projectRoot);
  const catalog = await fetchCatalog(config.registry);
  const installed = await listInstalled(projectRoot, config);

  const chosen = await chooseComponents(namesFromCli, catalog, installed);
  if (!chosen.length) {
    console.log('Nothing selected.');
    return;
  }

  /**
   * A component asked for by name is installed again even if it is present:
   * that is how a canon update lands, and it is the step the update recipe in
   * the README depends on. Dependencies pulled in behind it are only fetched
   * when missing.
   */
  const installedForClosure = new Set([...installed].filter((name) => !chosen.includes(name)));
  const toInstall = resolveClosure(chosen, catalog.byName, installedForClosure);
  if (!toInstall.length) {
    console.log('Nothing to install; the selections and their dependencies are already present.');
    return;
  }

  /**
   * Recording is on whenever this is a git repository and --no-commit was not
   * passed. A non-git consumer still gets the files, just no history.
   */
  const git = createGit(projectRoot);
  const inRepository = await git.isRepository();
  const recording = !noCommit && inRepository;
  if (!noCommit && !inRepository) {
    console.log('Not a git repository; installing without recording commits.');
  }

  /**
   * Preflight. An install overwrites whatever is in the component's directory,
   * so local edits sitting there uncommitted would be lost without a trace.
   * Refuse, and let --force say otherwise. This guards the files, not the
   * history, so it applies under --no-commit too.
   */
  if (inRepository && !force) {
    await assertPathsClean(
      git,
      toInstall.map((entry) => componentPath(entry, config))
    );
  }

  await installAll(toInstall, { config, git, recording });
};

// Run only when invoked directly, so the pure helpers above can be imported by
// tests without triggering a network install.
const invokedDirectly = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (invokedDirectly) {
  main().catch((error) => {
    console.error(`\nInstall failed: ${error.message}`);
    process.exit(1);
  });
}
