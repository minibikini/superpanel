#!/usr/bin/env coffee

program = require('commander')
pkg = require __dirname + "/../package"
defaultConfig = require __dirname + "/../config/config"

Path = require('path')
# _ = require 'lodash'
Promise = require 'bluebird'
glob = require 'glob'
# fs = Promise.promisifyAll require 'fs'



program
  .version(pkg.version)
  # .option('-p, --peppers', 'Add peppers')
  # .option('-P, --pineapple', 'Add pineapple')
  .option('-b, --build', 'Build the client app')
  .option '-p, --path [path/to/project]', 'path to the project folder (default is current directory)', '.'
  .parse(process.argv);

projectRoot = Path.resolve process.cwd(), program.path

runServer = ->
  server = require './server'
  logger = require './logger'

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


if program.build
  console.log 'build'
else
  runServer()