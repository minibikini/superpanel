#!/usr/bin/env node

var program = require('commander');
var pkg = require(__dirname + "/../package");
var Path = require('path');
require('coffee-react/register');

program
  .version(pkg.version)
  .option('-b, --build', 'Build the client app')
  .option('-s, --save-build-stats', 'Save build stats')
  .option('-w, --watch', 'Watch changes and rebuild the browser app')
  .option('-p, --path [path/to/project]', 'path to the project folder (default is current directory)', '.')
  .parse(process.argv);

var projectRoot = Path.resolve(process.cwd(), program.path);

module.exports = {
  projectRoot: projectRoot,
  program: program
};

require('./cli.coffee')