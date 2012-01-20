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