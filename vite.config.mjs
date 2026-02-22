import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import { scopedCSS } from 'ember-scoped-css/vite';

export default defineConfig({
  plugins: [
    classicEmberSupport(),
    ember(),
    scopedCSS({ layerName: 'components' }),
    // extra plugins here
    babel({
      babelHelpers: 'runtime',
      extensions,
      plugins: [
        'ember-concurrency/async-arrow-task-transform',
        // for ember-concurrency
        //['@babel/plugin-proposal-decorators', { legacy: true }],
        //['@babel/plugin-proposal-class-properties', { loose: true }],
        //['@babel/plugin-transform-class-static-block', { loose: true }],
      ]
    }),
  ],
});
