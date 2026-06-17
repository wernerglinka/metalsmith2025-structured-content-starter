import { Marked } from 'marked';
import imageWithClass from '@wernerglinka/marked-image-with-class';
import linkWithClass from '@wernerglinka/marked-link-with-class';
import paragraphWithClass from '@wernerglinka/marked-paragraph-with-class';
import directiveBlock from '@wernerglinka/marked-directive-block';

/**
 * A marked instance configured with the four content extensions from
 * https://github.com/wernerglinka/marked-extensions. They add Pandoc-style
 * class attributes to paragraphs, images, and links (`text {.class}`,
 * `![alt](src){.class}`, `[text](url){.class}`) plus triple-colon directive
 * blocks (`:::type ... :::`). The configuration stays scoped to this instance
 * rather than mutating the global marked singleton.
 */
const markedInstance = new Marked();

markedInstance.use({
  extensions: [paragraphWithClass(), imageWithClass(), linkWithClass(), directiveBlock()]
});

/**
 * Converts a markdown string to HTML.
 * @param {string} mdString - The markdown string to convert
 * @returns {string} The HTML output
 */
export const mdToHTML = (mdString) => {
  try {
    return markedInstance.parse(mdString, {
      mangle: false,
      headerIds: false
    });
  } catch (e) {
    console.error('Error parsing markdown:', e);
    return mdString;
  }
};
