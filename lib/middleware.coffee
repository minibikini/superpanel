_ = require 'lodash'
# send = require 'koa-send'
# publicPath = (require 'path').resolve __dirname, '../public'
# User = require './models/User'
logger = require './logger'
{copyObject} = require './helpers'

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
        error: copyObject error
      else "Server Error: #{error.message or error.status}"

      @app.emit 'error', error, @
