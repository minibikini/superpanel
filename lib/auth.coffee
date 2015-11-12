passport = require 'koa-passport'
LocalStrategy = require('passport-local').Strategy
# FacebookStrategy = require('passport-facebook').Strategy
users = require './users'
tokens = require './tokens'
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
    users.get(id).nodeify cb

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

  # passport.use new FacebookStrategy config.facebook, (accessToken, refreshToken, profile, done) ->
  #   User.getOrCreateByFB(profile._json, {accessToken, refreshToken}).nodeify done

  # scope = ['public_profile', 'email', 'user_friends', 'user_about_me', 'user_birthday', 'user_hometown', 'user_location']

  # app.get '/auth/facebook', setReturnTo, passport.authenticate('facebook', {scope})

  # app.get '/auth/facebook/callback', passport.authenticate('facebook', failureRedirect: '/loginfail'), afterLogin, ->
  #   @user = @passport.user

  #   if returnTo = @session.returnTo
  #     @session.returnTo = undefined
  #     @redirect returnTo
  #   else
  #     @redirect('/')

  rootRouter.get '/logout', ->
    yield @logout()
    @redirect('/')

  router = require('koa-router')
    prefix: '/api/auth'

  router.get '/logout', ->
    yield @logout() if @user
    @body = success: yes

  # router.post '/signup', ->
  #   @throw 404 unless config.auth.isOpenSignup

  #   if config.auth.local.isEmailRequired
  #     unless validator.isEmail @request.body.email
  #       @throw 400, "Enter a valid email",
  #         code: 'invalid_email'

  #   unless @request.body.password?.length >= 6
  #     @throw 400, "Password is too short",
  #       code: 'password_too_short'

  #   unless @request.body[config.auth.local.usernameField]
  #     @throw 400, "`#{config.auth.local.usernameField}` is required field",
  #       code: 'missing_requried_field'

  #   logger.debug "creating user", @request.body
  #   user = yield users.create @request.body

  #   # TODO send a signup message

  #   @body =
  #     success: user?
  #     emailConfirmationRequired: config.auth.local.isEmailConfirmationRequired

  # router.post '/request-reset-password', ->
  #   user = yield users.getByEmail @request.body.email
  #   @throw 404, "User is not found", code: 'user_isnt_found' unless user

  #   if config.auth.local.isEmailConfirmationRequired and not user.verifiedEmail
  #     @throw 400, "User is not verified yet", code: "email_isnt_verified_yet"

  #   token = yield tokens.create type: 'password_reset', userId: user.id
  #   logger.debug 'password reset token', token

  #   # TODO: send a password reset message

  #   @body =
  #     message: "We've sent you the password reset instuctions to your email."
  #     code: 'reset_email_sent'

  # router.post '/reset-password', ->
  #   {password, token} = @request.body
  #   password = (password or '').trim()

  #   token = yield tokens.get token

  #   @throw 400, "Invalid Token", code: 'invalid_token' unless token
  #   @throw 400, "Token Already Used", code: 'token_already_used' if token.isUsed
  #   @throw 400, "New password is too short", code: 'password_too_short' if password.length < 6

  #   {user} = yield Promise.props
  #     updatePassword: users.updatePassword token.userId, password
  #     use: users.use token.id
  #     user: users.get token.userId

  #   yield @login user

  #   # TODO: send password reset mail notification
  #   logger.debug 'password has been reset'

  #   @body = result: 'success', currentUser: user

  # router.post '/resend-confirmation', ->
  #   user = yield users.getByEmail @request.body.email
  #   @throw 404, "User not found", code: 'user_not_found' unless user
  #   @throw 400, "User is verified already", code: "verified_already" if user.verifiedEmail
  #   logger.debug 'resent confirmation email'

  #   # TODO: resent confirmation email
  #   # result = yield swu.send 'tem_xnWhzt8kmmKfkgBn2M5M5h', user.email, user
  #   # logger.debug 'resent confirmation email', result

  #   @body = success: yes

  # router.post '/confirmation', ->
  #   userId = @request.body.token

  #   user = yield User.get userId
  #   @throw 404, "Wrong token", code: 'user_not_found' unless user
  #   @throw 400, "User is verified already", code: "verified_already" if user.verifiedEmail

  #   {returnTo} = user
  #   user = yield User.updateAndReturn userId, verifiedEmail: yes, returnTo: null

  #   yield @login user

  #   phoneNumbers = yield Phone.getAllByUser(user.id).orderBy(r.desc 'createdAt').limit(4)
  #   user.isAdmin = yes if User.isAdmin user

  #   # yield swu.send 'tem_H7NWUHi626fmMLLw34zxCD', user.email, email: user.email

  #   @body = {result: 'success', currentUser: user, phoneNumbers, returnTo}

  router.post '/login', (next) ->
    loginCb = (err, user, info) =>
      console.log err, user, info
      @throw 400, err if err
      @throw 401, info unless user

      yield @login user

      @body = {user}

    yield passport.authenticate('local', loginCb).call(this, next)


  rootRouter.use router.routes()
