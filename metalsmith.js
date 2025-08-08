/**
 * Metalsmith Build Configuration
 *
 * This file configures how Metalsmith builds your site. Each section is documented
 * to help beginners understand what's happening at each step.
 */

// Apply File API polyfill if needed (for GitHub Actions compatibility)
import './file-polyfill.js';

// These are built-in Node.js modules needed for file paths and operations
import { fileURLToPath } from 'node:url'; // Converts file:// URLs to file paths
import path, { dirname } from 'node:path'; // Handles file paths across different OS
import * as fs from 'node:fs'; // File system operations (read/write files)

// The main Metalsmith library and plugins that transform your content
import Metalsmith from 'metalsmith'; // The core static site generator
import drafts from '@metalsmith/drafts'; // Excludes draft content from builds
import collections from '@metalsmith/collections';
import blogPages from 'metalsmith-sectioned-blog-pagination';
import permalinks from '@metalsmith/permalinks'; // Creates clean URLs
import menus from 'metalsmith-menu-plus'; // Generates navigation menus
import layouts from '@metalsmith/layouts'; // Applies templates to content
import safeLinks from 'metalsmith-safe-links';
import prism from 'metalsmith-prism';

import componentDependencyBundler from 'metalsmith-bundled-components';

import assets from 'metalsmith-static-files'; // Copies static assets to build
import htmlMinifier from 'metalsmith-optimize-html'; // Minifies HTML in production
import sitemap from 'metalsmith-sitemap'; // Generates a sitemap.xml file

import autoprefixer from 'autoprefixer'; // Adds browser prefixes to CSS
import cssnano from 'cssnano'; // Minifies CSS
import { performance } from 'perf_hooks'; // Measures build performance
import browserSync from 'browser-sync'; // Live-reload development server

// These variables help determine the current directory and file paths
const thisFile = fileURLToPath( import.meta.url ); // Gets the actual file path of this script
const thisDirectory = dirname( thisFile ); // Gets the directory containing this script
const mainFile = process.argv[ 1 ]; // Gets the file that was executed by Node.js

/**
 * ESM (ECMAScript Modules) doesn't support importing JSON directly
 * So we read the package.json file manually to get dependency information
 * @type {Object}
 */
const dependencies = JSON.parse( fs.readFileSync( './package.json' ) ).dependencies;

/**
 * @function getGlobalMetadata
 * @returns {Object} An object containing all JSON data files from lib/data directory
 *
 * This function reads all JSON files from the data directory and adds their data
 * to a metadata object. This object can then be added to the Metalsmith metadata.
 * /lib/data/
 *   - site.json
 *   - social.json
 *   - validate.json
 *
 * becomes
 * {
 *   site: {...},
 *   social: {...},
 *   validate: {...}
 * }
 */
const getGlobalMetadata = () => {
  const dataDir = path.join( thisDirectory, 'lib', 'data' ); // Path to data directory
  const files = fs.readdirSync( dataDir ); // Get all files in directory

  // Process each JSON file and add it to the result object
  return files.reduce( ( obj, file ) => {
    const fileName = file.replace( '.json', '' ); // Remove .json extension
    const fileContents = fs.readFileSync( path.join( dataDir, file ), 'utf8' );
    obj[ fileName ] = JSON.parse( fileContents ); // Parse JSON content
    return obj;
  }, {} );
};

const globalMetadata = getGlobalMetadata();

// Get the site URL for use in the sitemap plugin
const siteURL = globalMetadata.site.siteURL;

/**
 * TEMPLATE ENGINE SETUP
 * Import custom Nunjucks filters that extend the template engine
 * These filters provide additional functionality like date formatting,
 * string manipulation, and more.
 */
import * as nunjucksFilters from './nunjucks-filters/index.js';

/**
 * Configuration options for the Nunjucks template engine
 * @type {Object}
 */
const engineOptions = {
  path: [ 'lib/layouts' ], // Where to find template files
  filters: nunjucksFilters // Custom filters for templates
};

/**
 * ENVIRONMENT SETUP
 * Determine if we're in production mode based on NODE_ENV environment variable
 * @type {boolean}
 */
const isProduction = process.env.NODE_ENV !== 'development';

/**
 * Base path for serving the site in a subdirectory
 * e.g., https://example.com/subdirectory/
 * or https://wernerglinka.github.io/metalsmith2025-structured-content-starter/
 */
const basePath = process.env.BASE_PATH || '';

// Variable to hold the development server instance
let devServer = null;

/**
 * Create a new Metalsmith instance
 * This is the core object that will build our site
 * @type {Metalsmith}
 */
const metalsmith = Metalsmith( thisDirectory );

// Pass DEBUG environment variable if it exists
if ( process.env.DEBUG ) {
  metalsmith.env( 'DEBUG', process.env.DEBUG );
}

/**
 * Configure the basic Metalsmith settings
 * These determine how Metalsmith will process our files
 */
metalsmith
  // Clean the destination directory before building
  .clean( true )
  // Ignore macOS system files
  .ignore( [ '**/.DS_Store' ] )
  .watch( isProduction ? false : [ 'src/**/*', 'lib/layouts/**/*', 'lib/assets/**/*' ] )
  // Pass NODE_ENV to plugins
  .env( 'NODE_ENV', process.env.NODE_ENV )
  // Where to find source files
  .source( './src' )
  // Where to output the built site
  .destination( './build' )
  .metadata( {
    msVersion: dependencies.metalsmith,
    nodeVersion: process.version,
    ...globalMetadata
  } )

  // Exclude draft content in production mode
  .use( drafts( !isProduction ) )

  /**
   * Create a collection of blog posts
   * Learn more: https://github.com/metalsmith/collections
   */
  .use(
    collections( {
      blog: {
        pattern: 'blog/*.md',
        sortBy: 'card.date',
        reverse: false
      }
    } )
  )

  /**
   * Create metadata for blog pagination as pages are built
   * with individual page components so we can't use the
   * pagination plugin to do this.
   * Learn more: https://github.com/wernerglinka/metalsmith-sectioned-blog-pagination
   */
  .use(
    blogPages( {
      pagesPerPage: 4,
      blogDirectory: 'blog/'
    } )
  )

  /**
   * We are not using any markdown contents, only frontmatter
   * to define structured pages. Markdown content of section
   * properties will be done with a Nunjucks filter
   * Learn more: https://github.com/metalsmith/permalinks
   */
  .use(
    permalinks( {
      match: '**/*.md'
    } )
  )

  /**
   * Generate navigation menus
   * Learn more: https://github.com/wernerglinka/metalsmith-menu-plus
   */
  .use(
    menus( {
      metadataKey: 'mainMenu', // Where to store menu data
      usePermalinks: true, // Use clean URLs in menu
      navExcludePatterns: [ '404.html', 'robots.txt' ] // Files to exclude from menu
    } )
  )

  /*
    .use( function( files, metalsmith, done ) {
      console.log( 'meta:' );
      // log metadata as json string
      // Replace line 192 with:
      console.log( JSON.stringify( metalsmith.metadata().collections, ( key, value ) => {
        if ( key === 'previous' || key === 'next' ) {
          return value ? { title: value.title, path: value.path } : null;
        }
        return value;
      }, 2 ) );
      done();
    } )
  */

  /**
   * Apply templates to content
   * Learn more: https://github.com/metalsmith/layouts
   */
  .use(
    layouts( {
      directory: 'lib/layouts', // Where to find templates
      transform: 'nunjucks', // Template engine to use
      pattern: [ '**/*.html' ], // Files to apply templates to
      engineOptions // Options for the template engine
    } )
  )

  /**
   * Process all links so external links have
   * target="_blank" and rel="noopener noreferrer"
   * attributes and internal links are relative
   * This plugin also supports a basePath option which is necessary
   * when deploying a site to a subdirectory. In this case 'basePath'
   * is set above from the BASE_PATH environment variable.
   * Learn more: https://github.com/wernerglinka/metalsmith-safe-links
   */
  .use(
    safeLinks( {
      hostnames: [ 'http://localhost:3000/', 'wernerglinka.github.io' ],
      basePath: basePath
    } )
  )

  /**
   * Syntax highlight code blocks using Prism.js
   * Learn more: https://github.com/wernerglinka/metalsmith-prism
   */
  .use(
    prism( {
      decode: true
    } )
  )

  .use(
    componentDependencyBundler( {
      basePath: 'lib/layouts/components/_partials',
      sectionsPath: 'lib/layouts/components/sections',
      postcss: {
        enabled: true,
        plugins: [ autoprefixer(), cssnano( { preset: 'default' } ) ],
        options: {
          // Additional PostCSS options if needed
        }
      }
    } )
  )

  /**
   * Copy static assets to the build directory
   * Learn more: https://github.com/wernerglinka/metalsmith-static-files
   */
  .use(
    assets( {
      source: 'lib/assets/', // Where to find assets
      destination: 'assets/' // Where to copy assets
    } )
  );

// These plugins only run in production mode to optimize the site
if ( isProduction ) {
  metalsmith
    /**
     * Optimize HTML by Minify HTML to reduce file size
     * Learn more: https://github.com/wernerglinka/metalsmith-optimize-html
     */
    .use( htmlMinifier() )

    /**
     * Generate a sitemap.xml file for search engines
     * Learn more: https://github.com/ExtraHop/metalsmith-sitemap
     */
    .use(
      sitemap( {
        hostname: siteURL, // Your site's URL
        omitIndex: true, // Remove index.html from URLs
        omitExtension: true, // Remove .html extensions
        changefreq: 'weekly', // How often pages change
        lastmod: new Date(), // Last modification date
        pattern: [ '**/*.html', '!**/404.html' ], // Include all HTML except 404
        defaults: {
          priority: 0.5, // Default priority for pages
          changefreq: 'weekly', // Default change frequency
          lastmod: new Date() // Default last modified date
        }
      } )
    );
}

/**
 * BUILD EXECUTION
 * This section handles the actual build process and development server
 * It only runs when this file is executed directly (not when imported)
 */
if ( mainFile === thisFile ) {
  // Start timing the build for performance measurement
  let t1 = performance.now();

  // Execute the Metalsmith build
  metalsmith.build( ( err ) => {
    // Handle any build errors
    if ( err ) {
      throw err;
    }

    // Log build success and time taken
    /* eslint-disable no-console */
    console.log( `Build success in ${ ( ( performance.now() - t1 ) / 1000 ).toFixed( 1 ) }s` );

    // If watch mode is enabled, set up the development server
    if ( metalsmith.watch() ) {
      if ( devServer ) {
        t1 = performance.now();
        devServer.reload();
      } else {
        devServer = browserSync.create();

        const config = {
          host: 'localhost',
          port: 3000,
          injectChanges: false,
          reloadThrottle: 0
        };

        if ( basePath ) {
          // Serve with subdirectory simulation
          config.server = {
            baseDir: './build',
            routes: {
              [ `/${ basePath }` ]: './build'
            }
          };
          config.startPath = `/${ basePath }/`;
        } else {
          // Normal serving
          config.server = './build';
        }

        devServer.init( config );
      }
    }
  } );
}

// Export the Metalsmith instance for use in other files
export default metalsmith;
