program = require('commander')
pkg = require("../package.json")
Path = require('path')

program
  .version(pkg.version)
  .option('-b, --build', 'Build the client app')
  .option('-w, --watch', 'Watch changes and rebuild the browser app')
  .option('-p, --path [path/to/project]', 'path to the project folder (default is current directory)', '.')
  .parse(process.argv);

projectRoot = Path.resolve process.cwd(), program.path

module.exports = {projectRoot, program}
