_ = require 'lodash'
# send = require 'koa-send'
# publicPath = (require 'path').resolve __dirname, '../public'
# User = require './models/User'
logger = require './logger'
{copyObject} = require './helpers'

isDev = process.env.NODE_ENV isnt 'production'

module.exports =
  ensureAuthenticated: (next) ->
    if @isAuthenticated()
      yield next
    else
      @throw 403


  setupContext: (next) ->
    if @passport?.user
      @user = @state.user = @passport.user

    yield next

  responseTime: (next) ->
    start = new Date
    yield next
    ms = new Date - start
    @set('X-Response-Time', ms + 'ms')

  # staticFolder: (next) ->
  #   path = @path.split('/')[2..].join('/')
  #   if path.length
  #     yield send @, path, root: __dirname + '/../public', maxage: 315360000000
  #   else
  #     @throw 403

  setReturnTo: (next) ->
    @session.returnTo = @query.returnTo if @query.returnTo
    yield next

  errorHandler: (next) ->
    try
      yield next
    catch error
      requestBody = @request.body
      _.merge error, {remoteIp: @ip, @request, requestBody, refs: userId: @user?.id}
      error.code = 'not_found' if error.status is 404 and not error.code
      error.status ?= error.statusCode or 500

      @status = error.status

      @body = if @originalUrl.startsWith '/api'
        e = copyObject error
        e.message = error.message
        error: e
      else "Server Error: #{error.message or error.status}"

      @app.emit 'error', error, @

  serveIndex: ->
    yield []
    @body = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Superpanel</title>
        <link rel="stylesheet" href="/build/bundle.css">
    </head>
    <body>
    """
    @body += '   <script src="/webpack-dev-server.js"></script>' if isDev
    @body += """
      <script src="/build/bundle.js"></script>
    </body>
    </html>
    """