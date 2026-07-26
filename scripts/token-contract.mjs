/* eslint-disable no-console */

/**
 * Audit the token contract between this site and its installed components.
 *
 * Canon components consume design tokens with `var(--x)`. A token defined
 * nowhere fails silently: without a fallback the declaration is dropped at
 * computed-value time and simply does not apply, and with a fallback it
 * renders but cannot be retuned, which defeats the point of a token. Neither
 * case produces a build error, which is why this check exists.
 *
 * The "defined" universe a consumption is resolved against:
 *
 *   vocabulary - every custom property in lib/assets/styles/, the tokens
 *                this starter guarantees (see _design-tokens.css)
 *   components - properties any installed component defines itself, the
 *                `--<component>-*` design API
 *   overrides  - properties defined in lib/overrides/, the site layer
 *   vendor     - properties defined by self-hosted third-party stylesheets,
 *                when the packages are actually installed
 *
 * Scope is deliberately the installed contract: only the components present
 * in this site are audited. The canon-wide check lives in the library, where
 * every component is present (`npm run lint:components` there, with
 * `--vocab` pointing at this repository's lib/assets/styles).
 *
 * Usage:
 *   npm run tokens:check
 *   node scripts/token-contract.mjs --strict   # fail on warnings too
 *
 * Errors (missing token, no fallback) exit 1. Warnings (fallback-only)
 * exit 0 unless --strict.
 */

import fs from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(scriptDirectory, '..');

const VOCABULARY_DIR = 'lib/assets/styles';
const OVERRIDES_DIR = 'lib/overrides';

/**
 * Properties a component's template sets as an inline style per instance.
 * They are component parameters, not vocabulary, and a CSS-only scan cannot
 * see the definition. Mirrors the library lint's list.
 */
const TEMPLATE_SET = {
  'logos-list': new Set(['--single-list-width'])
};

/**
 * Vendor stylesheets whose property definitions count as "defined". Only
 * consulted when the package is actually installed, which in this starter
 * happens when a component that needs it is added.
 */
const VENDOR_CSS = [
  'node_modules/shikwasa/dist/style.css',
  'node_modules/leaflet/dist/leaflet.css',
  'node_modules/leaflet.markercluster/dist/MarkerCluster.css',
  'node_modules/leaflet.markercluster/dist/MarkerCluster.Default.css',
  'node_modules/ol/ol.css'
];

/**
 * Strip CSS comments so definitions and consumptions inside them are not
 * counted.
 * @param {string} css - Stylesheet source
 * @returns {string} Source without comments
 */
const stripComments = (css) => css.replace(/\/\*[\s\S]*?\*\//g, '');

/**
 * Every `--name:` definition in a CSS string.
 * @param {string} css - Stylesheet source
 * @returns {Set<string>} Property names
 */
const collectDefinitions = (css) => {
  const definitions = new Set();
  for (const match of stripComments(css).matchAll(/(--[a-z0-9-]+)\s*:/gi)) {
    definitions.add(match[1]);
  }
  return definitions;
};

/**
 * Every `var(--name[, fallback])` consumption in a CSS string, with the
 * line it appears on.
 * @param {string} css - Stylesheet source
 * @returns {Array<{name: string, hasFallback: boolean, line: number}>} Consumptions
 */
const collectConsumptions = (css) => {
  const uses = [];
  stripComments(css)
    .split('\n')
    .forEach((line, index) => {
      for (const match of line.matchAll(/var\(\s*(--[a-z0-9-]+)\s*(,)?/gi)) {
        uses.push({ name: match[1], hasFallback: Boolean(match[2]), line: index + 1 });
      }
    });
  return uses;
};

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
 * Concatenate every .css file under a directory, recursively.
 * @param {string} directory - Absolute path
 * @returns {Promise<string>} Combined CSS, empty when the directory is absent
 */
const readCssDir = async (directory) => {
  let css = '';
  let entries = [];
  try {
    entries = await fs.readdir(directory, { withFileTypes: true });
  } catch {
    return css;
  }
  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      css += await readCssDir(fullPath);
    } else if (entry.name.endsWith('.css')) {
      css += `\n${await fs.readFile(fullPath, 'utf-8')}`;
    }
  }
  return css;
};

/**
 * One installed component: its name and the stylesheets its manifest lists.
 * @param {string} directory - Absolute path to the component directory
 * @param {string} name - Component name
 * @returns {Promise<{name: string, cssFiles: string[]}|null>} The component, or null without a manifest
 */
const readComponent = async (directory, name) => {
  const manifestRaw = await readIfPresent(path.join(directory, 'manifest.json'));
  if (manifestRaw === null) {
    return null;
  }
  const manifest = JSON.parse(manifestRaw);
  const cssFiles = [];
  for (const file of manifest.styles ?? []) {
    const fullPath = path.join(directory, file);
    if ((await readIfPresent(fullPath)) !== null) {
      cssFiles.push(fullPath);
    }
  }
  return { name, cssFiles };
};

/**
 * The installed components: every directory with a manifest.json under the
 * configured component roots.
 * @param {object} config - Parsed nunjucks-components.config.json
 * @returns {Promise<Array<{name: string, cssFiles: string[]}>>} Components with their stylesheet paths
 */
const listInstalled = async (config) => {
  const components = [];
  for (const subDirectory of [config.sectionsDir, config.partialsDir]) {
    const root = path.join(projectRoot, config.componentsBasePath, subDirectory);
    let entries = [];
    try {
      entries = await fs.readdir(root, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const entry of entries.filter((item) => item.isDirectory())) {
      const component = await readComponent(path.join(root, entry.name), entry.name);
      if (component !== null) {
        components.push(component);
      }
    }
  }
  return components;
};

/**
 * Property definitions from the vendor stylesheets that are present.
 * @returns {Promise<Set<string>>} Property names
 */
const collectVendorDefinitions = async () => {
  const defined = new Set();
  for (const relativePath of VENDOR_CSS) {
    const contents = await readIfPresent(path.join(projectRoot, relativePath));
    if (contents === null) {
      continue;
    }
    for (const definition of collectDefinitions(contents)) {
      defined.add(definition);
    }
  }
  return defined;
};

/**
 * Read every component stylesheet and collect the properties they define.
 * @param {Array<{name: string, cssFiles: string[]}>} components - Installed components
 * @returns {Promise<{componentCss: Map<string, string>, componentDefined: Set<string>}>} Sources and definitions
 */
const loadComponentCss = async (components) => {
  const componentCss = new Map();
  const componentDefined = new Set();
  for (const component of components) {
    for (const file of component.cssFiles) {
      const css = await fs.readFile(file, 'utf-8');
      componentCss.set(file, css);
      for (const definition of collectDefinitions(css)) {
        componentDefined.add(definition);
      }
    }
  }
  return { componentCss, componentDefined };
};

/**
 * Check one stylesheet's consumptions against the defined universe.
 * @param {string} file - Absolute stylesheet path
 * @param {string} css - Stylesheet source
 * @param {function(string): boolean} isKnown - Whether a property is defined anywhere
 * @returns {{errors: string[], warnings: string[]}} Findings for this file
 */
const auditFile = (file, css, isKnown) => {
  const relativePath = path.relative(projectRoot, file);
  const errors = [];
  const warnings = [];
  for (const use of collectConsumptions(css)) {
    if (isKnown(use.name)) {
      continue;
    }
    if (use.hasFallback) {
      warnings.push(
        `${relativePath}:${use.line}: var(${use.name}, …) — token defined nowhere; the fallback is the only value there is`
      );
    } else {
      errors.push(
        `${relativePath}:${use.line}: var(${use.name}) — token defined nowhere; declaration is dropped at computed-value time`
      );
    }
  }
  return { errors, warnings };
};

/**
 * Print the findings and the summary line.
 * @param {{components: number, vocabulary: number, errors: string[], warnings: string[], strict: boolean}} result - Audit result
 */
const report = ({ components, vocabulary, errors, warnings, strict }) => {
  if (errors.length > 0) {
    console.log(`\n${errors.length} error(s):\n`);
    for (const message of errors) {
      console.log(`  ✖ ${message}`);
    }
  }
  if (warnings.length > 0) {
    console.log(`\n${warnings.length} warning(s):\n`);
    for (const message of warnings) {
      console.log(`  ! ${message}`);
    }
  }
  if (errors.length === 0 && warnings.length === 0) {
    console.log('token contract: clean');
  }
  console.log(
    `\ntoken contract: ${components} installed components, ${vocabulary} vocabulary tokens, ${errors.length} errors, ${warnings.length} warnings${strict ? ' (strict)' : ''}`
  );
};

const main = async () => {
  const strict = process.argv.includes('--strict');
  const config = JSON.parse(await fs.readFile(path.join(projectRoot, 'nunjucks-components.config.json'), 'utf-8'));
  const components = await listInstalled(config);

  const vocabulary = collectDefinitions(await readCssDir(path.join(projectRoot, VOCABULARY_DIR)));
  const overrideDefined = collectDefinitions(await readCssDir(path.join(projectRoot, OVERRIDES_DIR)));
  const vendorDefined = await collectVendorDefinitions();
  const { componentCss, componentDefined } = await loadComponentCss(components);

  const errors = [];
  const warnings = [];
  for (const component of components) {
    const isKnown = (name) =>
      vocabulary.has(name) ||
      componentDefined.has(name) ||
      overrideDefined.has(name) ||
      vendorDefined.has(name) ||
      Boolean(TEMPLATE_SET[component.name]?.has(name));
    for (const file of component.cssFiles) {
      const findings = auditFile(file, componentCss.get(file), isKnown);
      errors.push(...findings.errors);
      warnings.push(...findings.warnings);
    }
  }

  report({ components: components.length, vocabulary: vocabulary.size, errors, warnings, strict });
  process.exit(errors.length > 0 || (strict && warnings.length > 0) ? 1 : 0);
};

await main();
