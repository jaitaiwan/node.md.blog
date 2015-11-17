//Setup auto compilation files...
require('coffee-script').register();
require('eco');
require.extensions['.styl'] = function (module, filename) {
  var content = require('fs').readFileSync(filename, 'utf8');
  var style = require('stylus')(content).render();
  module.exports = style;
};