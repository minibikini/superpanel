startedAt = Date.now()
Promise = require 'bluebird'
Promise.config warnings: off

logger = require './logger'
ResourceSchema = require './ResourceSchema'
{buildDirName} = require '../config/system-names'
process.on 'uncaughtException', (err) ->
  logger.error err
mount = require 'koa-mount'
compress = require 'koa-compress'
Router = require('koa-router')
passport = require('koa-passport')

{authentication, setupContext, responseTime, staticFolder, errorHandler, serveIndex} = require './middleware'

module.exports = (resources, controllers, projectRoot) ->
  config = require '../config/config'

  app = require('koa')()
  app.isProd = app.env is 'production'
  app.name = config.name
  app.keys = config.sessionKeys
  require('koa-qs')(app)
  app.use errorHandler
  app.use responseTime
  app.use require('koa-cors')()
  app.use compress() if app.isProd
  # app.use require('koa-favicon')(__dirname + '/../public/favicon.ico')
  app.use require('koa-static')(projectRoot + '/public')
  app.use require('koa-static')(__dirname + '/../public')
  # app.use mount '/st', staticFolder

  unless app.isProd
    app.use require('koa-logger')()
    # koaLogger = require('koa-bunyan')
    # app.use koaLogger logger, timeLimit: 1000

  app.use require('koa-session')({key: '_sp', maxage: 1000 * 3600 * 24 * 30}, app)

  app.use require('koa-conditional-get')()
  app.use require('koa-etag')()

  # parses the hidden _method field in forms to emit RESTful routing with HTML Forms.
  app.use require('koa-overwrite')()

  # auth
  app.use passport.initialize()
  app.use passport.session()

  app.use setupContext
  app.use require('koa-json')(pretty: no, param: 'pretty')

  app.use authentication

  router = new Router()
  require('./auth')(router)
  if config.uiUrl
    router.get config.uiUrl, serveIndex

  app.use router.routes()

  app.use mount '/api/_config', ->
    yield []
    @body = {resources}

  # create api for apis
  for resource in resources
    resource = new ResourceSchema resources, resource
    logger.debug "setting up `#{resource.getUrl()}`"
    app.use mount resource.getUrl(), require('./restApiController')(resource)

  for path, controller of controllers
    logger.debug "setting up `#{path}`"
    app.use mount path, controller

  app.on 'error', (err, ctx) ->
    logger.error err if err.status not in [403, 404]

  app.listen config.port, '0.0.0.0', ->
    app.emit "http.listen"
    time = Date.now() - startedAt
    logger.info "Started in #{time} ms"
    logger.info "Listening at 0.0.0.0:#{config.port}"
