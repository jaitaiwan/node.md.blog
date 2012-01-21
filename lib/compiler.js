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
