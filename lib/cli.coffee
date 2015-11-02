pkg = require __dirname + "/../package"
defaultConfig = require __dirname + "/../config/config"

# _ = require 'lodash'
Promise = require 'bluebird'
glob = require 'glob'
# fs = Promise.promisifyAll require 'fs'
logger = require './logger'


{projectRoot, program} = require './cli.js'

runServer = ->
  server = require './server'

  getResourcesList = ->
    new Promise (resolve, reject) ->
      glob "*/", cwd: "#{projectRoot}/resources" , (err, data) ->
        return reject err if err
        resolve (folder[...-1] for folder in data)


  getSchema = (path) ->
    new Promise (resolve, reject) ->
      glob "**/*", cwd: "#{projectRoot}/resources/#{path}" , (err, data) ->
        return reject err if err
        for f in data when f?.startsWith 'schema.'
          file = f
          break

        # console.log path, file, file?.startsWith 'schema.', data

        if file
          resolve require "#{projectRoot}/resources/#{path}/#{file}"
        else
          resolve {path}

  getControllers = (resources) ->
    controllers = {}

    getController = (path) ->
      new Promise (resolve, reject) ->
        glob "**/*", cwd: "#{projectRoot}/resources/#{path}" , (err, data) ->
          return reject err if err
          for f in data when f?.startsWith 'controller.'
            file = f
            break

          if file
            controllers["/api/#{path}"] = require "#{projectRoot}/resources/#{path}/#{file}"

          resolve()

    Promise.map(resources, getController).then -> controllers


  begin = Date.now()
  getResourcesList().then (resources) ->
    Promise.props
      schema: Promise.map resources, getSchema
      controllers: getControllers resources
    .then ({schema, controllers}) ->
      logger.debug "Loaded schema in #{Date.now() - begin} ms"
      server schema, controllers
      # logger.debug schema


if program.build or program.watch
  webpack = require("webpack")
  compiler = webpack require("../webpack.config")

  if program.build
    buildBeginAt = Date.now()
    logger.info "Building the browser app"
    compiler.run (err, stats) ->
      logger.error err if err?
      logger.debug stats.toString(colors: true)
      logger.info "Build done in #{Date.now() - buildBeginAt} ms"

  if program.watch
    logger.info "Watch changes and rebuild the browser app"
    compiler.watch {aggregateTimeout: 300}, (err, stats) ->
      logger.error err if err?
      logger.debug stats.toString(colors: true)
      logger.info "Bundle updated"

    # WebpackDevServer = require("webpack-dev-server")
    # server = new WebpackDevServer compiler,
    #   publicPath: require("../webpack.config").output.publicPath
    #   stats:
    #     colors: true
    #   hot: true
    #   historyApiFallback: true
    #   # // webpack-dev-server options
    #   # contentBase: '../public/build/'
    #   # // or:
    #   # contentBase: "http://localhost:8181/build/",
    #   # headers: { "Access-Control-Allow-Origin": "*" }
    #   proxy: {
    #     "*": "http://localhost:1337"
    #   }

    #   # // webpack-dev-middleware options
    #   # quiet: false,
    #   # noInfo: false,
    #   # lazy: true,
    #   # watchOptions: {
    #   #   aggregateTimeout: 300,
    #   #   poll: 1000
    #   # },

    # server.listen 8181, "localhost", ->
    #   logger.info "Dev server is ready"
else
  runServer()