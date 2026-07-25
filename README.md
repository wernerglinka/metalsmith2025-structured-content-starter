<p align="center">
  <a href="https://www.metalsmith.io">
    <img alt="Metalsmith" src="https://www.glinka.co/assets/images/metalsmith2025-logo-bug.png" width="80" />
  </a>
</p>
<h1 align="center">
  Metalsmith2025 Structured Content Starter
</h1>

This is a component-based, structured content starter built with Metalsmith, demonstrating modern web development patterns without the overhead of JavaScript frameworks. Unlike traditional lonf-text Markdown contents, this starter uses structured content in frontmatter to define reusable page sections and components. Each component manages its own styles and scripts, which are automatically bundled only when used. This approach provides the flexibility of component-driven development while maintaining the simplicity and performance benefits of static site generation with Metalsmith.

[Explore the demo](https://ms2025-structured-content-starter.netlify.app/).

## Features

### Component-Based Architecture

- **Structured Content**: Define pages using structured data in frontmatter instead of Markdown body content
- **Reusable Components**: Build pages from modular section components (hero, banner, media, etc.)
- **Component Dependency Bundling**: Automatically bundles only the CSS and JavaScript needed for components used on each page
- **No Framework Overhead**: Get the benefits of component architecture without React, Vue, or other JavaScript frameworks

### Modern Development Patterns

- **Component Manifests**: Each component has a manifest.json defining its dependencies and configuration
- **PostCSS Processing**: Built-in autoprefixing and CSS optimization through the componentDependencyBundler
- **Separation of Concerns**: Components maintain their own styles, scripts, and templates
- **Flexible Section System**: Mix and match different section types to create unique page layouts

### Content Management

- **Frontmatter-Driven**: All page content and structure defined in frontmatter
- **Blog System**: Full-featured blog with pagination, but using structured content approach
- **Section-Based Pages**: Build complex layouts by composing section components
- **Clean URLs**: Permalinks for SEO-friendly URLs

### SEO Features

This starter includes several SEO-friendly features:

- **Sitemap Generation**: A sitemap.xml file is automatically generated in production builds
- **Robots.txt**: A robots.txt file is included and processed with Nunjucks
- **404 Page**: A custom 404 error page that works with Netlify and other hosting providers
- **SEO Metadata**: Each page can include custom title, description, and social image metadata

### Component Dependency Bundler

The `componentDependencyBundler` plugin is a key differentiator of this starter:

- **Automatic Dependency Resolution**: Scans your pages to identify which components are used
- **Smart Bundling**: Creates optimized CSS and JavaScript bundles containing only the code for components actually used
- **PostCSS Processing**: Applies autoprefixing and minification to component styles
- **Performance Optimized**: Reduces payload by excluding unused component code
- **Component Isolation**: Each component's styles and scripts are scoped and managed independently

### Development Experience

- **Live Reloading**: Development server with automatic browser refresh
- **Code Quality Tools**: ESLint and Prettier integration for consistent code style
- **Optimized Build**: HTML minification for production builds
- **Combined Scripts**: Run `npm run fix` to format and lint your code in one command

## Getting started

You need Node.js version 18 or higher.

1.  **Create a Metalsmith site.**

    Clone the starter repository to create a new blog.

    ```shell
    git clone https://github.com/wernerglinka/metalsmith2025-structured-content-starter my-site
    ```

1.  **Start developing.**

    Navigate into your new site’s directory and start it up.

    ```shell
    cd my-site/
    npm install
    npm start
    ```

1.  **Open the source code and start editing!**

    Your site is now running at `http://localhost:3000`!

    Open the `src` directory in your code editor of choice and edit any page's frontmatter to modify its sections. Save your changes and the browser will update in real time!

1.  **Initialize the page shell.**

    The frame every page shares (head, header, footer, navigation, branding, breadcrumbs) is the **page shell**, kept in `lib/layouts/pages/parts/` and `lib/assets/styles/` rather than the component catalog, so you edit it directly. Three pieces are optional; set them up interactively:

    ```shell
    npm run init
    ```

    This asks y/n for each optional feature and wires your choices in: the **dark/light theme switcher** (off by default), the **language switcher** (off by default), and **breadcrumbs** (on by default, turn it off for small sites). Two need a one-time setup once enabled: the language switcher reads `lib/data/languages.json`, and the theme switcher needs `.dark-theme` overrides for your design tokens to theme the whole page. See [docs/page-shell.md](docs/page-shell.md), [docs/theme-switcher.md](docs/theme-switcher.md), and [docs/language-switcher.md](docs/language-switcher.md). To change one feature without the prompts: `node scripts/init-starter.mjs disable breadcrumbs`.

1.  **Available scripts**

    This starter includes several useful scripts:

    ```shell
    npm run init   # Set up page-shell features (interactive)
    npm start      # Start development server with live reloading
    npm run dev    # Run a development build
    npm run build  # Create a production build
    npm run serve  # Serve the build directory with Browser-Sync
    npm run format # Format code with Prettier
    npm run lint   # Lint and fix code with ESLint
    npm run fix    # Run both format and lint in sequence
    ```

## What's included?

A quick look at the top-level files and directories you'll see in this Metalsmith project.

    .
    ├── node_modules/            # Dependencies
    ├── src/                     # Source content (structured frontmatter)
    ├── lib/                     # Project assets, components, and templates
    │   ├── assets/              # Static assets (images, global CSS)
    │   ├── data/                # Global data files (JSON)
    │   ├── plugins/             # Site-owned build plugins (data-loader)
    │   └── layouts/             # Templates and components
    │       ├── components/      # Reusable components
    │       │   ├── _helpers/    # Template helpers
    │       │   ├── _partials/   # Partial components (buttons, cards, etc.)
    │       │   └── sections/    # Section components (hero, banner, etc.)
    │       └── pages/           # Page templates and pages/parts/ (the page shell)
    ├── nunjucks-filters/        # Custom Nunjucks filters
    ├── eslint.config.js         # ESLint configuration
    ├── .gitattributes           # Git attributes configuration
    ├── .gitignore               # Git ignore rules
    ├── .prettierignore          # Prettier ignore rules
    ├── prettier.config.js       # Prettier configuration
    ├── LICENSE                  # License file
    ├── metalsmith.js            # The build pipeline, every plugin in order
    ├── site-config.js           # Build configuration values
    ├── package-lock.json        # Dependency lock file
    ├── package.json             # Project manifest
    └── README.md                # Project documentation

1. **`node_modules`**: This directory contains all the node modules that your project depends on.

2. **`src`**: This directory contains all the content that makes up your site:
   - **`src/index.md`**: Homepage with structured sections in frontmatter
   - **`src/blog.md`**: Blog index page using blog-list section component
   - **`src/blog/`**: Individual blog posts with structured frontmatter
   - **`src/sections.md`**: Example page showcasing various section components
   - **`src/404.html`**: Custom 404 error page
   - **`src/robots.txt`**: SEO-friendly robots.txt file

3. **`lib`**: This directory contains all the project assets and templates:
   - **`lib/assets`**: Static assets like images and global CSS
   - **`lib/data`**: JSON data files for global site configuration
   - **`lib/layouts`**: Templates and components:
     - **`components/_partials`**: Reusable UI components (buttons, cards, etc.)
     - **`components/sections`**: Page section components (hero, banner, media blocks, etc.)
     - **`pages`**: Page-level templates that compose sections
     - **`pages/parts`**: The page shell (head, header, footer, navigation, branding, breadcrumbs); see [docs/page-shell.md](docs/page-shell.md)

4. **Component Structure**: Each component typically includes:
   - **`component-name.njk`**: The component's template
   - **`component-name.css`**: Component-specific styles
   - **`component-name.js`**: Component-specific JavaScript (if needed)
   - **`manifest.json`**: Component metadata and dependencies
   - **`README.md`**: Component documentation

5. **`nunjucks-filters`**: Custom filters for the Nunjucks templating engine including markdown processing, date formatting, and more

6. **`eslint.config.js`**: This file contains all rules for ESLint.

7. **`.gitattributes`**: This file tells git how it should handle line endings.

8. **`.gitignore`**: This file tells git which files it should not track / not maintain a version history for.

9. **`.prettierignore`**: This file tells prettier what files it should ignore.

10. **`prettier.config.js`**: This is a configuration file for [Prettier](https://prettier.io/). Prettier is a tool to help keep the formatting of your code consistent.

11. **`eslint.config.js`**: This is a configuration file for [ESLint](https://eslint.org/). ESLint is a tool to help keep the formatting of your code consistent.

12. **`LICENSE`**: This Metalsmith starter is licensed under the MIT license.

13. **`metalsmith.js`**: This is the Metalsmith build file that includes the componentDependencyBundler plugin for managing component assets.

14. **`package-lock.json`** (See `package.json` below, first). This is an automatically generated file based on the exact versions of your npm dependencies that were installed for your project. **(You won’t change this file directly).**

15. **`package.json`**: A manifest file for Node.js projects, which includes things like metadata (the project’s name, author, etc). This manifest is how npm knows which packages to install for your project.

16. **`README.md`**: A text file containing useful reference information about your project.

## How Structured Content Works

This starter takes a different approach from traditional Markdown-based static sites:

### Content Definition

Pages are defined using structured data in frontmatter rather than Markdown content. For example:

```yaml
sections:
  - sectionType: hero
    text:
      title: 'Welcome to My Site'
      prose: 'This content is defined in structured data'
    containerFields:
      background:
        image: '/assets/images/hero.jpg'
  - sectionType: banner
    text:
      title: 'Another Section'
      prose: 'Each section is a reusable component'
```

### Component System

- **Section Components**: Large page sections like hero, banner, media blocks
- **Partial Components**: Smaller reusable elements like buttons and cards
- **Template Helpers**: Utilities for rendering sections and building attributes
- **Page Shell**: The frame around content (head, header, footer, navigation, branding, breadcrumbs) lives in `pages/parts/`, not the catalog; see [Page Shell](docs/page-shell.md)

### Automatic Asset Management

The `componentDependencyBundler` automatically:

1. Scans your pages to identify which components are used
2. Bundles only the CSS and JavaScript for those components
3. Applies PostCSS processing (autoprefixing, minification)
4. Outputs optimized per-page stylesheets and scripts

## The Build

The build is two files, and the split between them is the point.

`metalsmith.js` is the pipeline. Every plugin is visible, in the order it runs, so you can read top to bottom and see what happens to your content on the way to `build/`. It has no site-specific values in it, which is why you can copy it to the next site nearly verbatim.

`site-config.js` is the values: paths, collections, pagination, permalinks, menus, SEO, watch paths. No logic, no plugin names, no conditionals. It is grouped in pipeline order, so the two files read in parallel. This is the file you edit when starting a site.

Content-facing metadata (site title, URL, SEO defaults) lives in `lib/data/site.json` and is read from there. Keeping it out of `site-config.js` is deliberate: two homes for one value is how they drift apart.

A stage a site does not use is deleted rather than switched off in config. If the pipeline starts branching on whether a config key exists, the build has quietly turned back into a framework.

### Why Metalsmith is pinned to 2.6.3

2.7 introduced `statik()`, which copies directories under `src/` to the build without passing them through the file tree. Two things break under it, and both are silent.

Watch mode stops rebuilding, because 2.7 watches through chokidar 4, which dropped glob support, and the watch paths are globs. And responsive images stop being generated, because `metalsmith-optimize-images` cannot resolve an image that never entered the file tree: every lookup fails, no `<img>` is rewritten, and the build reports success. The second one is worse than it sounds, since an incremental build finds last build's images still on disk and partly works, so the failure only shows up on a clean checkout.

So assets live in `lib/assets/` and are copied by `metalsmith-static-files` after image optimization, which is how this starter worked before 2.7. Revisit when 2.7 is fixed upstream.

### Why the generated image variants are committed

`lib/assets/images/responsive/` holds the output of `metalsmith-optimize-images` and is checked into git on purpose, even though it is build output.

It is a cache. Committing it means CI does not regenerate every variant on every deploy, which is the difference between a fast build and a slow one. It also sidesteps a plugin bug: a build against an empty cache emits the source height with the resized width, so a cold CI build ships images with a distorted aspect ratio. Keeping the cache warm in the repo keeps the markup correct.

Replacing the sample images leaves stale variants behind. Delete the directory and rebuild to regenerate it.

## Installing Components

`npm run components` lists every catalog component not yet in the site and installs the ones you pick, along with any dependencies they need. Naming components directly installs them without the prompt:

```shell
npm run components                                # pick from the list
node scripts/install-components.mjs hero banner   # install by name
```

A component named on the command line is installed again even if it is already present, which is how you pull a canon update. Dependencies are only fetched when missing.

### Installs Are Recorded in Git

Each installed component lands as its own commit, staged from that component's directory only, so unrelated work in progress stays out of it:

```
component: install hero@1.3.1 from nunjucks-components.com

Component-Name: hero
Component-Version: 1.3.1
Content-Hash: a3f9c2e17b40d8e6
```

The version is the library's, not the component's: components are published as a set, so `1.3.1` says which library release this copy of `hero` came from. `Content-Hash` is the per-component identity, and it is the field that moves when the component's own content changes.

The trailers make an install mechanically findable later, with no lockfile or sidecar file to keep in sync. What landed and from which release is a `git log` away, and what you changed since is one diff:

```shell
git log --grep="Component-Name: hero" -1
git diff <that commit> HEAD -- lib/layouts/components/sections/hero
```

Because an install overwrites whatever is in the component's directory, the installer refuses to run when those paths have uncommitted changes, rather than discarding edits it cannot recover. Two flags adjust this:

- `--force` installs anyway, discarding local edits in the affected component directories
- `--no-commit` places files without recording commits, for sites not kept in git

`--no-commit` still honors the dirty-path refusal, since that guard protects your files rather than your history. Outside a git repository the installer says so and simply places the files.

### Updating a Component You Have Customized

Components are yours once installed. Edit them freely; the cost is that adopting a later canon version is a merge rather than a copy. Git already knows how to do that merge, and the install commit is what gives it something to merge against.

Four steps. Say you have edited `hero` and want the current canon version.

**1. Find the commit where it was installed.**

```shell
git log --grep="Component-Name: hero" -1 --format=%H
```

**2. Save what you changed since.**

```shell
git diff <install-commit> HEAD -- lib/layouts/components/sections/hero > /tmp/hero.patch
```

That patch is your fork: every edit you made on top of the version you installed, and nothing else.

**3. Reinstall from canon.**

```shell
git status --porcelain -- lib/layouts/components/sections/hero   # must be empty
node scripts/install-components.mjs hero
```

Naming the component explicitly reinstalls it even though it is present. The canon files land, and a fresh install commit records the new version. Your edits are gone from the working tree at this point, which is fine, because step 2 has them.

**4. Reapply your edits.**

```shell
git apply --3way /tmp/hero.patch
```

`--3way` merges rather than applying blindly, so edits to lines canon did not touch land silently and genuine collisions come back as ordinary conflict markers for you to resolve. Build, check the result, then commit the reapplied customization as its own commit so the next update has a clean baseline to diff from.

If the patch applies cleanly and the component still looks right, you are done. If it conflicts, the conflict is the useful part: it is the exact place where canon changed something you had also changed.

### Updating a Component Installed Before Install Commits Existed

Components installed by hand, or by the per-component `install.sh` scripts, have no install commit to diff against. There is no baseline in your history, so make one from canon instead:

```shell
curl -sO https://nunjucks-components.com/downloads/partials/text.zip
unzip -q text.zip -d /tmp/canon
diff -ru /tmp/canon/text lib/layouts/components/_partials/text
```

Read that diff in both directions. Lines only in your copy are your customizations. Lines only in canon are improvements you never received, which is the part that is easy to miss. Decide file by file: a manifest is usually safe to take wholesale, while CSS you have edited deserves a real merge. Commit the result with the same trailers the installer writes, so the next update has a baseline:

```
component: update text@1.3.1 manifest from nunjucks-components.com

Component-Name: text
Component-Version: 1.3.1
Content-Hash: bdce80ff48392bc5
```

`version` and `contentHash` come from the canon catalog at `https://nunjucks-components.com/downloads/manifest.json`, where `version` is the library release and `contentHash` identifies this component's content.

## Content Validation

This starter includes built-in validation to catch common configuration errors:

- **Type validation**: Ensures booleans are actual booleans (not strings like `"false"`)
- **Enum validation**: Validates values like `titleTag` (h1-h6) and `buttonStyle` (primary, secondary, ghost)
- **Component validation**: Ensures referenced section types exist

See [Content Validation Guide](docs/VALIDATION.md) for complete details.

## Learn more about Metalsmith

Looking for more guidance? Full documentation for Metalsmith can be found [on the Metalsmith website](https://www.metalsmith.io).

## Deploy

Deploy and Host on any static hosting service. For example [Netlify](https://www.netlify.com), [Vercel](https://vercel.com/) or [Cloudflare Pages](https://pages.cloudflare.com/).

Here is an article about [how to deploy Metalsmith on Netlify](https://www.netlify.com/blog/2015/12/08/a-step-by-step-guide-metalsmith-on-netlify/). The process is similar for this Metalsmith2025 Structured Content Starter.

### Deploying to a Subdirectory

When deploying your site to a subdirectory path (such as GitHub Pages at `https://username.github.io/repository-name/`), special configuration is required to ensure all assets and links work correctly. Without proper handling, your CSS, JavaScript, images, and internal links will break because they'll point to the wrong paths.

This starter is using the [metalsmith-safe-links](https://github.com/wernerglinka/metalsmith-safe-links) plugin for subdirectory deployments. It automatically handles path prefixing for all your site's resources. This plugin:

- Automatically prefixes all relative URLs with the correct base path
- Processes all HTML elements with URLs (links, images, scripts, stylesheets, etc.)
- Handles both absolute and relative URL conversion
- Adds proper attributes to external links (target="\_blank", rel="noopener noreferrer")

To configure your site for subdirectory deployment, ensure the `metalsmith-safe-links` plugin is properly configured in your `metalsmith.js` build file with the appropriate base path for your deployment target. Without this plugin, your deployed site will have broken styling, missing images, and non-functional navigation.

## Development

### Template Formatting

Some Nunjucks templates use dynamic HTML tags (e.g., user-configurable header levels) which are excluded from Prettier formatting due to parser limitations. See `.prettierignore` and `CONTRIBUTING.md` for specific files and details.

### Running the Project

- `npm start` - Start development server with watch mode
- `npm run build` - Build for production
- `npm test` - Run test suite
- `npm run format` - Format code with Prettier

## Join the Metalsmith community at [Gitter](https://gitter.im/metalsmith/community).

