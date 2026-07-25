/* eslint-disable no-console */

/**
 * Report which installed components are out of date, which you have changed,
 * and which are both.
 *
 * Components are published as a set, so the catalog's `version` is the
 * library's release and cannot tell you whether one component moved between
 * two releases. `contentHash` can: it is a hash of the component's own files,
 * and it is what changes when the component's content changes.
 *
 * This script compares three hashes per component:
 *
 *   local    - computed here, from the files on disk
 *   canon    - the catalog's contentHash for that component
 *   baseline - the Content-Hash trailer of the last install commit, i.e. what
 *              canon looked like when you installed it
 *
 * Local against canon says whether the files differ. The baseline is what
 * makes the difference attributable: if local still matches the baseline then
 * canon moved and you did not, and if canon still matches the baseline then
 * you moved and canon did not.
 *
 * Usage:
 *   npm run components:status
 *   node scripts/component-status.mjs --json
 *
 * Note: the hash covers the template, the stylesheet, the script and any
 * modules. It does not cover manifest.json, so a manifest-only change on
 * either side is invisible here. `diff -ru` against a fresh download is the
 * way to see those.
 */

import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createGit } from './install-components.mjs';

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(scriptDirectory, '..');

/**
 * Read a file, returning null when it does not exist.
 * @param {string} filePath - Absolute path
 * @returns {Promise<string|null>} Contents, or null
 */
const readIfPresent = async (filePath) => {
  try {
    return await fs.readFile(filePath, 'utf-8');
  } catch {
    return null;
  }
};

/**
 * Every .js file under a component's modules directory, depth first, in
 * directory-entry order. Mirrors how the canon packager walks them, which is
 * what makes the hash comparable.
 * @param {string} modulesPath - Absolute path to the modules directory
 * @returns {Promise<string[]>} File contents in traversal order
 */
const loadModules = async (modulesPath) => {
  const contents = [];
  const walk = async (dirPath) => {
    let entries = [];
    try {
      entries = await fs.readdir(dirPath, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      const fullPath = path.join(dirPath, entry.name);
      if (entry.isDirectory()) {
        await walk(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.js')) {
        contents.push(await fs.readFile(fullPath, 'utf-8'));
      }
    }
  };
  await walk(modulesPath);
  return contents;
};

/**
 * Compute a component's content hash the way the canon packager does:
 * sha256 over the template, then the stylesheet, then the script, then any
 * modules, truncated to 16 characters. The manifest is deliberately not part
 * of it.
 *
 * @param {string} componentPath - Absolute path to the component directory
 * @param {string} name - Component name
 * @returns {Promise<string|null>} The hash, or null when there is no template
 */
export async function contentHash(componentPath, name) {
  const template = await readIfPresent(path.join(componentPath, `${name}.njk`));
  if (template === null) {
    return null;
  }

  const hash = crypto.createHash('sha256');
  hash.update(template);

  const styles = await readIfPresent(path.join(componentPath, `${name}.css`));
  if (styles !== null) {
    hash.update(styles);
  }

  const scripts = await readIfPresent(path.join(componentPath, `${name}.js`));
  if (scripts !== null) {
    hash.update(scripts);
  }

  for (const moduleContent of await loadModules(path.join(componentPath, 'modules'))) {
    hash.update(moduleContent);
  }

  return hash.digest('hex').substring(0, 16);
}

/**
 * Decide what a component's three hashes mean.
 *
 * @param {Object} hashes - The three hashes
 * @param {string} hashes.local - Hash of the files on disk
 * @param {string} [hashes.canon] - Catalog hash, absent for a component not in the catalog
 * @param {string} [hashes.baseline] - Hash recorded at install time, absent without an install commit
 * @returns {{status: string, detail: string}} Status and a one-line explanation
 */
export function classify({ local, canon, baseline }) {
  if (!canon) {
    return { status: 'local-only', detail: 'not in the catalog' };
  }
  if (local === canon) {
    return { status: 'current', detail: 'matches canon' };
  }
  if (!baseline) {
    return { status: 'differs', detail: 'differs from canon, no install commit to attribute it' };
  }
  if (local === baseline) {
    return { status: 'outdated', detail: 'canon moved, your copy did not' };
  }
  if (canon === baseline) {
    return { status: 'modified', detail: 'you changed it, canon did not' };
  }
  return { status: 'diverged', detail: 'you changed it and canon moved' };
}

/**
 * The Content-Hash trailer of a component's last install commit.
 *
 * @param {Object} git - Git helpers
 * @param {string} name - Component name
 * @returns {Promise<string|null>} The recorded hash, or null when there is no install commit
 */
export async function baselineHash(git, name) {
  const message = await git.lastInstallMessage(name);
  if (!message) {
    return null;
  }
  const match = message.match(/^Content-Hash:\s*(\S+)$/m);
  return match ? match[1] : null;
}

/**
 * Read the project config.
 * @param {string} root - Project root
 * @returns {Promise<Object>} Parsed config
 */
const loadConfig = async (root) => {
  const raw = await fs.readFile(path.join(root, 'nunjucks-components.config.json'), 'utf8');
  return JSON.parse(raw);
};

/**
 * Fetch the canonical catalog, indexed by component name.
 * @param {string} registry - Canonical site origin
 * @returns {Promise<Map<string, Object>>} Catalog entries by name
 */
const fetchCatalog = async (registry) => {
  const url = `${registry.replace(/\/$/, '')}/downloads/manifest.json`;
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Could not fetch catalog at ${url} (${response.status})`);
  }
  const manifest = await response.json();
  return new Map([...(manifest.sections || []), ...(manifest.partials || [])].map((entry) => [entry.name, entry]));
};

/**
 * Every installed component, with the directory it lives in.
 * @param {string} root - Project root
 * @param {Object} config - Project config
 * @returns {Promise<Array<{name: string, path: string, relative: string}>>} Installed components
 */
const listInstalled = async (root, config) => {
  const found = [];
  for (const dir of [config.sectionsDir, config.partialsDir]) {
    const parent = path.join(root, config.componentsBasePath, dir);
    let entries = [];
    try {
      entries = await fs.readdir(parent, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const entry of entries.filter((e) => e.isDirectory())) {
      found.push({
        name: entry.name,
        path: path.join(parent, entry.name),
        relative: `${config.componentsBasePath}/${dir}/${entry.name}`
      });
    }
  }
  return found.sort((a, b) => a.name.localeCompare(b.name));
};

/**
 * Build the status report for every installed component.
 * @returns {Promise<Array<Object>>} One row per component
 */
const report = async () => {
  const config = await loadConfig(projectRoot);
  const catalog = await fetchCatalog(config.registry);
  const installed = await listInstalled(projectRoot, config);
  const git = createGit(projectRoot);
  const inRepository = await git.isRepository();

  const rows = [];
  for (const component of installed) {
    const local = await contentHash(component.path, component.name);
    if (local === null) {
      continue;
    }
    const entry = catalog.get(component.name);
    const baseline = inRepository ? await baselineHash(git, component.name) : null;
    const { status, detail } = classify({ local, canon: entry?.contentHash, baseline });
    rows.push({
      name: component.name,
      path: component.relative,
      status,
      detail,
      local,
      canon: entry?.contentHash ?? null,
      baseline
    });
  }
  return rows;
};

/**
 * Print the report as a table grouped by status.
 * @param {Array<Object>} rows - Report rows
 * @returns {void}
 */
const printReport = (rows) => {
  const order = ['diverged', 'outdated', 'modified', 'differs', 'local-only', 'current'];
  const width = Math.max(...rows.map((row) => row.name.length), 4);

  for (const status of order) {
    const group = rows.filter((row) => row.status === status);
    if (!group.length) {
      continue;
    }
    console.log(`\n${status} (${group.length})`);
    for (const row of group) {
      console.log(`  ${row.name.padEnd(width)}  ${row.detail}`);
    }
  }

  const outdated = rows.filter((row) => row.status === 'outdated' || row.status === 'diverged');
  if (outdated.length) {
    console.log(
      `\nTo update: node scripts/install-components.mjs ${outdated.map((row) => row.name).join(' ')}` +
        '\nFor anything you have customized, follow the update recipe in the README first,' +
        '\nso your changes can be reapplied after the reinstall.'
    );
  }
  console.log('\nThe hash covers template, styles, scripts and modules. Manifest-only');
  console.log('changes are invisible here; diff against a fresh download to see those.');
};

const invokedDirectly = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (invokedDirectly) {
  report()
    .then((rows) => {
      if (process.argv.includes('--json')) {
        console.log(JSON.stringify(rows, null, 2));
        return;
      }
      printReport(rows);
    })
    .catch((error) => {
      console.error(`\nStatus check failed: ${error.message}`);
      process.exit(1);
    });
}
