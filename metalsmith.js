/**
 * Metalsmith Build Pipeline
 *
 * This file is the build. Every plugin is visible, in the order it runs, so
 * you can read the whole pipeline top to bottom and see what happens to your
 * content on the way to `build/`.
 *
 * Values live in site-config.js; mechanism lives here. The two files read in
 * parallel, because the config is grouped in pipeline order. In practice you
 * copy this file between sites nearly verbatim and edit site-config.js.
 *
 * Run directly (`node metalsmith.js`) to build, add --watch for the dev
 * server. Imported, it exports the configured Metalsmith instance without
 * building, which is how the `metalsmith -c metalsmith.js` CLI uses it.
 */

// Apply File API polyfill if needed (for GitHub Actions compatibility)
import './file-polyfill.js';

import * as fs from 'node:fs'; // File system operations (read/write files)
import path, { dirname } from 'node:path'; // Handles file paths across different OS
import { performance } from 'node:perf_hooks'; // Measures build performance
import { fileURLToPath } from 'node:url'; // Converts file:// URLs to file paths

import collections from '@metalsmith/collections'; // Groups content into named lists
import drafts from '@metalsmith/drafts'; // Excludes draft content from builds
import layouts from '@metalsmith/layouts'; // Applies templates to content
import permalinks from '@metalsmith/permalinks'; // Creates clean URLs
import autoprefixer from 'autoprefixer'; // Adds browser prefixes to CSS
import cssnano from 'cssnano'; // Minifies CSS
import Metalsmith from 'metalsmith'; // The core static site generator
import componentDependencyBundler from 'metalsmith-bundled-components';
import menus from 'metalsmith-menu-plus'; // Generates navigation menus
import htmlMinifier from 'metalsmith-optimize-html'; // Minifies HTML in production
import optimizeImages from 'metalsmith-optimize-images'; // Optimizes images for web
import safeLinks from 'metalsmith-safe-links';
import blogPages from 'metalsmith-sectioned-blog-pagination';
import seo from 'metalsmith-seo'; // Adds SEO metadata to pages
import assets from 'metalsmith-static-files'; // Copies static assets to the build

import dataLoader from './lib/plugins/data-loader.js';
import * as nunjucksFilters from './nunjucks-filters/index.js';
import config from './site-config.js';

const thisFile = fileURLToPath(import.meta.url); // The actual path of this script
const thisDirectory = dirname(thisFile); // The directory containing this script
const mainFile = process.argv[1]; // The file Node.js was asked to run

/**
 * Configuration options for the Nunjucks template engine.
 * The filters are what templates call as `{{ value | filterName }}`.
 */
const engineOptions = {
  path: [config.layouts.directory],
  filters: nunjucksFilters
};

/** Production is the default; the dev scripts set NODE_ENV=development */
const isProduction = process.env.NODE_ENV !== 'development';

/**
 * Base path for serving the site in a subdirectory,
 * e.g. https://wernerglinka.github.io/metalsmith2025-structured-content-starter/
 */
const basePath = process.env.BASE_PATH || '';

/** ESM cannot import JSON directly, so package.json is read from disk */
const dependencies = JSON.parse(fs.readFileSync(path.join(thisDirectory, 'package.json'), 'utf8')).dependencies;

const metalsmith = Metalsmith(thisDirectory);

// Pass the DEBUG environment variable through to the plugins that honor it
if (process.env.DEBUG) {
  metalsmith.env('DEBUG', process.env.DEBUG);
}

metalsmith
  // Empty the destination directory before each build
  .clean(config.build.clean)
  // Files never read from the source, macOS system files by default
  .ignore(config.build.ignore)
  // Watch these paths in development; never in production
  .watch(isProduction ? false : config.watch.paths)
  // Pass NODE_ENV to plugins
  .env('NODE_ENV', process.env.NODE_ENV)
  .source(config.source)
  .destination(config.destination)
  .metadata({
    msVersion: dependencies.metalsmith,
    nodeVersion: process.version
  })

  /**
   * 1. Data files
   * Every JSON file under lib/data becomes a key on metadata.data, so
   * lib/data/site.json is available in templates as data.site. This runs on
   * every build, so data edits are picked up during watch mode.
   */
  .use(dataLoader({ directory: config.data.directory }))

  /** 2. Drafts are visible in development, excluded from production builds */
  .use(drafts(!isProduction))

  /**
   * 3. Collections
   * Groups content into named, sorted lists that listing pages read.
   * Learn more: https://github.com/metalsmith/collections
   */
  .use(collections(config.collections));

/**
 * 4. Pagination
 * One pass per paginated listing page. Pages here are built from components
 * rather than markdown bodies, so the standard pagination plugin does not
 * apply.
 * Learn more: https://github.com/wernerglinka/metalsmith-sectioned-blog-pagination
 */
for (const paginationConfig of config.pagination) {
  metalsmith.use(blogPages(paginationConfig));
}

metalsmith
  /**
   * 5. Permalinks
   * Clean URLs: /page/ rather than /page.html. Content is structured
   * frontmatter rather than markdown bodies, so nothing else is needed here.
   * Learn more: https://github.com/metalsmith/permalinks
   */
  .use(permalinks(config.permalinks));

/**
 * 6. Navigation menus
 * One pass per menu, each writing its own tree into metadata under its
 * metadataKey, so templates can render several independent navigations.
 * Learn more: https://github.com/wernerglinka/metalsmith-menu-plus
 */
for (const menuConfig of config.menus) {
  metalsmith.use(
    menus({
      metadataKey: menuConfig.metadataKey,
      usePermalinks: menuConfig.usePermalinks,
      navExcludePatterns: menuConfig.exclude,
      ...(menuConfig.rootPath ? { rootPath: menuConfig.rootPath } : {})
    })
  );
}

metalsmith
  /**
   * 7. Layouts
   * Renders each page's sections through the Nunjucks templates.
   * Learn more: https://github.com/metalsmith/layouts
   */
  .use(
    layouts({
      directory: config.layouts.directory,
      transform: config.layouts.transform,
      pattern: config.layouts.pattern,
      engineOptions
    })
  )

  /**
   * 8. Safe links
   * External links get target="_blank" and rel="noopener noreferrer";
   * internal links are made relative and get the BASE_PATH prefix when the
   * site is deployed to a subdirectory.
   * Learn more: https://github.com/wernerglinka/metalsmith-safe-links
   */
  .use(
    safeLinks({
      hostnames: config.links.hostnames,
      basePath
    })
  )

  /**
   * 9. Component bundler
   * Resolves the dependency tree of the components each page uses and bundles
   * only their CSS and JS, through esbuild with PostCSS.
   * Learn more: https://github.com/wernerglinka/metalsmith-bundled-components
   */
  .use(
    componentDependencyBundler({
      basePath: `${config.components.basePath}/${config.components.partialsDir}`,
      sectionsPath: `${config.components.basePath}/${config.components.sectionsDir}`,
      schema: config.components.schema,
      postcss: {
        enabled: true,
        plugins: [autoprefixer(), cssnano({ preset: config.components.minifyPreset })],
        options: {}
      }
    })
  );

/**
 * 10. Image optimization, production only.
 * Generates the responsive variants and rewrites <img> tags into srcsets.
 * Runs before the static copy so the variants are in place when it happens.
 * Learn more: https://github.com/wernerglinka/metalsmith-optimize-images
 */
if (isProduction) {
  metalsmith.use(optimizeImages(config.optimizeImages));
}

/**
 * 11. Static assets
 * Copies lib/assets to the build untouched, minus the CSS and JS entry
 * points the bundler already handled.
 * Learn more: https://github.com/wernerglinka/metalsmith-static-files
 */
metalsmith.use(
  assets({
    source: config.staticFiles.source,
    destination: config.staticFiles.destination,
    ignore: config.staticFiles.ignore
  })
);

/**
 * The last two only run in production, where the cost is worth paying.
 */
if (isProduction) {
  metalsmith
    /**
     * 12. SEO
     * Open Graph tags, Twitter cards, JSON-LD, a sitemap and robots.txt.
     * Learn more: https://github.com/wernerglinka/metalsmith-seo
     */
    .use(seo(config.seo))

    /**
     * 13. HTML minification
     * Learn more: https://github.com/wernerglinka/metalsmith-optimize-html
     */
    .use(htmlMinifier(config.optimizeHtml));
}

/**
 * Build execution.
 *
 * Only runs when this file is executed directly, so importing it (as the
 * Metalsmith CLI does) just hands back the configured instance. In watch mode
 * each rebuild reloads the BrowserSync server, which is imported lazily so a
 * production build does not need the dev dependency installed.
 */
if (mainFile === thisFile) {
  let devServer = null;
  let t1 = performance.now();

  metalsmith.build(async (err) => {
    if (err) {
      throw err;
    }

    console.log(`Build success in ${((performance.now() - t1) / 1000).toFixed(1)}s`);

    if (!metalsmith.watch()) {
      return;
    }

    if (devServer) {
      t1 = performance.now();
      devServer.reload();
      return;
    }

    const { default: browserSync } = await import('browser-sync');
    devServer = browserSync.create();

    const serverConfig = { ...config.devServer };

    if (basePath) {
      // Serve with subdirectory simulation
      serverConfig.server = {
        baseDir: config.destination,
        routes: { [`/${basePath}`]: config.destination }
      };
      serverConfig.startPath = `/${basePath}/`;
    } else {
      serverConfig.server = config.destination;
    }

    devServer.init(serverConfig);
  });
}

// Export the Metalsmith instance for the CLI and for tests
export default metalsmith;
