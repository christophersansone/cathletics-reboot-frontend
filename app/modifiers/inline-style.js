import Modifier from 'ember-modifier';
import { dasherize } from '@ember/string';

/* Pass a hash as the first argument, or just inline the styles themsleves.  Examples:
  {{inline-style (hash zIndex=this.zIndex)}}
  {{inline-style this.styles}}
  {{inline-style zIndex=this.zIndex}}
*/

export default class InlineStyleModifier extends Modifier {
  existingStyles = new Set();

  modify(element, [positionalStyleHash], inlineStyles) {
    const styleHash = positionalStyleHash || inlineStyles;
    this.setStyles(element, styleHash);
  }

  setStyles(element, styleHash) {
    const rulesToRemove = new Set(this.existingStyles);
    const newStyles = new Set();

    Object.entries(styleHash).forEach(([property, value]) => {
      const p = dasherize(property);
      let priority = '';
      if (value && value.toString().includes('!important')) {
        priority = 'important';
        value = value.replace('!important', '');
      }

      element.style.setProperty(p, value, priority);

      newStyles.add(p);
      rulesToRemove.delete(p);
    });

    rulesToRemove.forEach((rule) => element.style.removeProperty(rule));
    this.existingStyles = newStyles;
  }

}
