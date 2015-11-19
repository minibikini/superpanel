passport = require 'koa-passport'
LocalStrategy = require('passport-local').Strategy
users = require './users'
config = require '../config/config'
logger = require './logger'
Promise = require 'bluebird'

module.exports = (rootRouter)->
  require('koa-router')

  passport.serializeUser (user, cb) ->
    if user and user.id
      cb null, user.id
    else
      logger.error "serializeUser", user
      cb "Something went wrong. Please, try again."

  passport.deserializeUser (id, cb) ->
    users.get(id).asCallback cb

  localOpts =
    usernameField: config.auth.local.usernameField

  passport.use new LocalStrategy localOpts, (username, password, done) ->
    users.getByUsername(username)
      .catch done
      .then (user) ->
        unless user
          return done null, false, "User Is Not Found", code: 'user_not_found'

        if config.auth.local.isEmailConfirmationRequired
          unless user.verifiedEmail
            return done null, false, message: "Email is not confirmed", code: 'not_confirmed_email'

        if users.validatePassword(user, password)
          done null, user
        else
          done null, false, message: 'Incorrect password', code: 'bad_password'

  rootRouter.get '/logout', ->
    yield []
    @logout()
    @redirect('/')

  router = require('koa-router')
    prefix: '/api/auth'

  router.get '/logout', ->
    yield @logout() if @user
    @body = success: yes

  router.post '/login', (next) ->
    loginCb = (err, user, info) =>
      @throw 400, err if err
      @throw 401, info unless user

      yield @login user
      yield users.updateLastLoginAt user.id

      @body = {user}

    yield passport.authenticate('local', loginCb).call(this, next)


  rootRouter.use router.routes()
