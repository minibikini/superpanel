#!/usr/bin/env node

var program = require('commander');
var pkg = require(__dirname + "/../package");
var Path = require('path');
require('coffee-react/register');

program
  .version(pkg.version)
  .option('-b, --build', 'Build the client app')
  .option('-d, --dev', 'Run the server in development mode')
  .option('-s, --save-build-stats', 'Save build stats')
  .option('-w, --watch', 'Watch changes and rebuild the browser app')
  .option('-p, --path [path/to/project]', 'path to the project folder (default is current directory)', '.')
  .parse(process.argv);

var projectRoot = Path.resolve(process.cwd(), program.path);

if (program.dev) {
  var logger = require('./logger')
  var nodemon = require('nodemon');

  var ignore = [
    projectRoot + "/public",
    projectRoot + "/.git",
    projectRoot + '/client',
    __dirname + '/../scss',
    __dirname + '/../client'
  ];

  nodemon({
    script: __dirname + '/cli.js',
    ext: 'js json coffee jsx cjsx',
    watch: ['*.*', Path.resolve(__dirname, '..')],
    ignore: ignore,
    env: {
      NODE_ENV: "development"
    }
  });

  logger.info('Starting the server in DEVELOPMENT mode');

  nodemon.on('start', function () {
    // logger.info('App has started');
  }).on('restart', function (files) {
    logger.info('The server restarted due to: ', files)
  });
}
else {
  module.exports = {
    projectRoot: projectRoot,
    program: program
  };

  require('./cli.coffee')
}
