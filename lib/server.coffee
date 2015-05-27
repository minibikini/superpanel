startedAt = Date.now()

logger = require './logger'

process.on 'uncaughtException', (err) ->
  logger.error 'uncaughtException', err

# mount = require 'koa-mount'
compress = require 'koa-compress'
# Router = require('koa-router')

{setupContext, responseTime, staticFolder, errorHandler} = require './middleware'

config = require '../config/config'

app = require('koa')()
app.isProd = app.env is 'production'
app.name = config.name
# app.keys = ['GkgwaQi4546', 'LHGsfDs3dK1', 'PjhFf45d876', 'mhUE$5TYGJyrt', 'K@7g%0Hfb2']


app.use errorHandler
app.use responseTime
app.use require('koa-cors')()
app.use compress() if app.isProd
# app.use require('koa-favicon')(__dirname + '/../public/favicon.ico')
app.use require('koa-static')(__dirname + '/../public')
# app.use mount '/st', staticFolder

unless app.isProd
  app.use require('koa-logger')()
  # koaLogger = require('koa-bunyan')
  # app.use koaLogger logger, timeLimit: 1000

# app.use require('koa-session')({key: 'se', maxage: 1000 * 3600 * 24 * 30}, app)

app.use require('koa-conditional-get')()
app.use require('koa-etag')()

# TODO: remove global parser; make parsing inside route
# app.use require('koa-body')()
# app.use require('koa-overwrite')()
# app.use passport.initialize()
# app.use passport.session()

# app.use setupContext
app.use require('koa-json')(pretty: no, param: 'pretty')



app.on 'error', (err, ctx) ->
  logger.error err if err.status not in [403, 404]

app.listen config.web.port, ->
  app.emit "http.listen"
  time = Date.now() - startedAt
  logger.info "Started in #{time} ms"
  logger.info "Listening at http://localhost:#{config.web.port}/"