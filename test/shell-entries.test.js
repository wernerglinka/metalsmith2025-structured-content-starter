/**
 * Page shell entry points
 *
 * The component bundler is told where the page shell lives through
 * `config.components.mainCSSEntry` and `mainJSEntry`. If those paths go
 * stale (a folder rename, say) the bundler silently builds without the
 * design tokens and base styles and every page renders unstyled, while the
 * build itself still succeeds. This test fails instead.
 */
import { strict as assert } from 'node:assert';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { describe, it } from 'node:test';
import { fileURLToPath } from 'node:url';
import config from '../site-config.js';

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');

describe('Page shell entries', () => {
  it('should point the bundler at shell entry files that exist', () => {
    for (const key of ['mainCSSEntry', 'mainJSEntry']) {
      const entry = config.components[key];
      assert.equal(typeof entry, 'string', `config.components.${key} must be set explicitly`);
      assert.ok(existsSync(join(projectRoot, entry)), `${key} "${entry}" does not exist`);
    }
  });

  it('should resolve every @import in the CSS manifest', () => {
    const manifest = join(projectRoot, config.components.mainCSSEntry);
    const css = readFileSync(manifest, 'utf8');
    const imports = [...css.matchAll(/@import\s+url\(["']?([^"')]+)["']?\)/g)].map((m) => m[1]);
    assert.ok(imports.length > 0, 'the CSS manifest should import the shell stylesheets');
    for (const target of imports) {
      assert.ok(
        existsSync(join(dirname(manifest), target)),
        `import "${target}" in ${config.components.mainCSSEntry} does not resolve`
      );
    }
  });
});
