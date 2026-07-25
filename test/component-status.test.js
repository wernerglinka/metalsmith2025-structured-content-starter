/**
 * @fileoverview Unit tests for the component status check: the content hash
 * (which must reproduce what the canon packager computes) and the
 * classification that turns three hashes into an attributable status.
 */

import { strict as assert } from 'node:assert';
import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { after, before, describe, it } from 'node:test';
import { classify, contentHash } from '../scripts/component-status.mjs';

describe('component status', () => {
  describe('contentHash()', () => {
    let root;

    before(async () => {
      root = await fs.mkdtemp(path.join(os.tmpdir(), 'component-status-'));
    });

    after(async () => {
      await fs.rm(root, { recursive: true, force: true });
    });

    /**
     * Write a component directory.
     * @param {string} name - Component name
     * @param {Object} files - Files to write, keyed by filename
     * @returns {Promise<string>} Path to the component directory
     */
    const makeComponent = async (name, files) => {
      const dir = path.join(root, name);
      await fs.mkdir(dir, { recursive: true });
      for (const [file, contents] of Object.entries(files)) {
        const target = path.join(dir, file);
        await fs.mkdir(path.dirname(target), { recursive: true });
        await fs.writeFile(target, contents);
      }
      return dir;
    };

    it('hashes template, styles and scripts in that order, truncated to 16 chars', async () => {
      const dir = await makeComponent('hero', {
        'hero.njk': '<section class="hero"></section>',
        'hero.css': '.hero { color: red; }',
        'hero.js': 'console.log("hero");'
      });

      const expected = crypto
        .createHash('sha256')
        .update('<section class="hero"></section>')
        .update('.hero { color: red; }')
        .update('console.log("hero");')
        .digest('hex')
        .substring(0, 16);

      assert.equal(await contentHash(dir, 'hero'), expected);
    });

    it('handles a component with only a template', async () => {
      const dir = await makeComponent('bare', { 'bare.njk': '<div></div>' });
      const expected = crypto.createHash('sha256').update('<div></div>').digest('hex').substring(0, 16);
      assert.equal(await contentHash(dir, 'bare'), expected);
    });

    it('includes modules', async () => {
      const dir = await makeComponent('withmods', {
        'withmods.njk': '<div></div>',
        'modules/a.js': 'export const a = 1;'
      });
      const without = crypto.createHash('sha256').update('<div></div>').digest('hex').substring(0, 16);
      assert.notEqual(await contentHash(dir, 'withmods'), without);
    });

    it('ignores the manifest, which is why manifest-only changes are invisible', async () => {
      const dir = await makeComponent('manifested', {
        'manifested.njk': '<div></div>',
        'manifest.json': '{"name":"manifested"}'
      });
      const before = await contentHash(dir, 'manifested');
      await fs.writeFile(path.join(dir, 'manifest.json'), '{"name":"manifested","fields":{}}');
      assert.equal(await contentHash(dir, 'manifested'), before);
    });

    it('changes when the stylesheet changes', async () => {
      const dir = await makeComponent('styled', {
        'styled.njk': '<div></div>',
        'styled.css': '.a {}'
      });
      const before = await contentHash(dir, 'styled');
      await fs.writeFile(path.join(dir, 'styled.css'), '.b {}');
      assert.notEqual(await contentHash(dir, 'styled'), before);
    });

    it('returns null when there is no template', async () => {
      const dir = await makeComponent('templateless', { 'notes.md': 'hello' });
      assert.equal(await contentHash(dir, 'templateless'), null);
    });
  });

  describe('classify()', () => {
    it('reports a component absent from the catalog as local-only', () => {
      assert.equal(classify({ local: 'aaa', canon: undefined, baseline: undefined }).status, 'local-only');
    });

    it('reports a match with canon as current', () => {
      assert.equal(classify({ local: 'aaa', canon: 'aaa', baseline: 'aaa' }).status, 'current');
    });

    it('reports canon moving while the local copy stood still as outdated', () => {
      assert.equal(classify({ local: 'aaa', canon: 'bbb', baseline: 'aaa' }).status, 'outdated');
    });

    it('reports a local edit against unchanged canon as modified', () => {
      assert.equal(classify({ local: 'bbb', canon: 'aaa', baseline: 'aaa' }).status, 'modified');
    });

    it('reports both sides moving as diverged', () => {
      assert.equal(classify({ local: 'bbb', canon: 'ccc', baseline: 'aaa' }).status, 'diverged');
    });

    it('does not attribute a difference when there is no install commit', () => {
      const result = classify({ local: 'bbb', canon: 'aaa', baseline: null });
      assert.equal(result.status, 'differs');
      assert.match(result.detail, /no install commit/);
    });

    it('reports current even without a baseline when the files match canon', () => {
      assert.equal(classify({ local: 'aaa', canon: 'aaa', baseline: null }).status, 'current');
    });
  });
});
