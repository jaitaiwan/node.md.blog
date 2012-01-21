//Setup auto compilation files...
var fs, compilers, cs;
fs = require('fs');
compilers = {};
try {
	cs = require('coffee-script');
	compilers.coffee = function (path) {
		return cs.compile(fs.readFileSync(path, 'utf8'), {filename: path});
	}

} catch (err) {}

try {
	eco = require('eco');
	require.extensions[".eco"] = function(module, filename) {
		var source;
		source = require("fs").readFileSync(filename, "utf-8");
		return module._compile("module.exports = " + (eco(source)), filename);
	};
} catch (err) {}

var stylus;

try {
  stylus = require('stylus');
  compilers.styl = function(path) {
    var content, result;
    content = fs.readFileSync(path, 'utf8');
    dirname = require('path').dirname;
    result = '';
    stylus(content).include(dirname(path)).render(function(err, css) {
      if (err) throw err;
      return result = css;
    });
    return result;
  };
  require.extensions['.styl'] = function(module, filename) {
    var source;
    source = JSON.stringify(compilers.styl(filename));
    return module._compile("module.exports = " + source, filename);
  };
} catch (err) {}
