/**
 * Site Configuration
 *
 * Values only. No logic, no plugin names, no conditionals, no environment
 * checks. Everything here is something you can change without understanding
 * the build; `metalsmith.js` holds the mechanism and reads these values in
 * the same order the pipeline runs, so the two files read in parallel.
 *
 * This is the file you edit when starting a site. `metalsmith.js` is the file
 * you copy from site to site and rarely touch.
 *
 * One-home rule: content-facing metadata (site title, URL, SEO defaults)
 * lives in lib/data/site.json and is read from there. This file is build
 * configuration only. Do not duplicate values across the two.
 */

export default {
  /** Where content comes from and where the built site goes */
  source: './src',
  destination: './build',

  /**
   * Empty the destination before each build, and files never to read from
   * the source in the first place.
   */
  build: {
    clean: true,
    ignore: ['**/.DS_Store']
  },

  /** JSON files loaded into metadata.data (lib/data/site.json -> data.site) */
  data: {
    directory: 'lib/data'
  },

  /**
   * Files copied to the build without processing. They live outside src/ so
   * they never enter the file tree as pages, and the copy runs after image
   * optimization so the generated variants are already in place.
   */
  staticFiles: {
    source: 'lib/assets/',
    destination: 'assets/',
    ignore: ['main.css', 'main.js', 'styles/']
  },

  /** Named collections. Sort accepts any frontmatter path, plus :asc or :desc */
  collections: {
    blog: {
      pattern: 'blog/*.md',
      sort: 'card.date:desc'
    }
  },

  /**
   * Paginated listing pages. Pages are built from components rather than
   * markdown bodies, so this is not the standard pagination plugin.
   */
  pagination: [
    {
      pagesPerPage: 4,
      blogDirectory: 'blog/'
    }
  ],

  /** Clean URLs: /page/ rather than /page.html */
  permalinks: {
    match: '**/*.md'
  },

  /**
   * Navigation menus. Each entry builds an independent tree in metadata
   * under its own metadataKey, so a site can have several.
   */
  menus: [
    {
      metadataKey: 'mainMenu',
      usePermalinks: true,
      exclude: ['404.html', 'robots.txt']
    }
  ],

  /** Nunjucks templates */
  layouts: {
    directory: 'lib/layouts',
    pattern: ['**/*.html'],
    transform: 'nunjucks'
  },

  /** Hostnames treated as internal, so their links stay relative */
  links: {
    hostnames: ['http://localhost:3000/', 'wernerglinka.github.io']
  },

  /**
   * Component dependency bundler. Only the CSS and JS of components a page
   * actually uses gets bundled. The path keys match what the component
   * install scripts expect in nunjucks-components.config.json.
   */
  components: {
    basePath: 'lib/layouts/components',
    sectionsDir: 'sections',
    partialsDir: '_partials',
    /** cssnano preset used when minifying the bundled CSS */
    minifyPreset: 'default',
    /** Emit the composed editor schema for the in-situ editor to consume */
    schema: {
      enabled: true
    },
    /**
     * Cascade layers. Each component's CSS is wrapped in
     * @layer components.<name>, and lib/overrides/<name>/<name>.css in
     * @layer site.<name>, so an override wins over the component it
     * overrides without needing a more specific selector, and canon
     * component files never have to be edited in place.
     *
     * The order below is the whole cascade of the site, lowest first.
     * Anything left unlayered would beat all of it, which is why every
     * import in lib/assets/main.css names its layer.
     *
     * `vendor` sits between `base` and `components` for third-party widget
     * CSS (Leaflet, OpenLayers, Shikwasa): it must beat the generic element
     * styles in `base`, while a component that deliberately restyles a
     * widget must beat the vendor defaults. No installed component ships
     * vendor CSS yet, so the layer is empty, but it is declared here so the
     * slot exists. If you install a component that injects a vendor
     * stylesheet at runtime, copy that file into the build wrapped in
     * `@layer vendor { ... }`; a plain <link> is unlayered CSS and would
     * beat every layer, including your own `site` overrides.
     */
    layers: {
      enabled: true,
      order: ['tokens', 'base', 'vendor', 'components', 'site']
    }
  },

  /**
   * Responsive image variants, production only.
   *
   * `cache` keeps the generated variants in lib/assets/images/responsive so a
   * rebuild does not redo the work. It also tells the plugin where the source
   * images live, which is what lets it rewrite <img> tags into srcsets when
   * the images are copied to the build rather than passed through the file
   * tree. Without it, nothing is rewritten.
   */
  optimizeImages: {
    isProgressive: false,
    cache: true
  },

  /**
   * Metadata, social cards, structured data, sitemap and robots.txt.
   * Production only. Site metadata is read from metadata.data.site,
   * i.e. lib/data/site.json.
   */
  seo: {
    metadataPath: 'data.site'
  },

  /** HTML minification, production only. Defaults are fine. */
  optimizeHtml: {},

  /** Paths watched in development, each change triggering a rebuild */
  watch: {
    paths: ['src/**/*', 'lib/layouts/**/*', 'lib/assets/**/*', 'lib/data/**/*']
  },

  /** Development server. These keys are passed to BrowserSync as they are. */
  devServer: {
    host: 'localhost',
    port: 3000,
    injectChanges: false,
    reloadThrottle: 0
  }
};
