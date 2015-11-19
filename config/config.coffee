_ = require 'lodash'
{projectRoot} = require '../lib/program'

try
  config = require "#{projectRoot}/config/config"
catch e
  if e.code is 'MODULE_NOT_FOUND'
    config = {}
  else throw e


getRandomSessionKeys = ->
  for i in [1..5]
    _.random(1000000000000000, 9999999999999999).toString(36)

config = _.defaultsDeep config,
  name: 'superpanel'
  timezone: '+07:00'
  currency: 'USD'
  port: 1337

  rethinkdb:
    db: 'superpanel'

  # api:
  #   showLinks: yes

  uiUrl: '/'

  auth:
    isOpenSignup: no
    local:
      usernameField: 'email'
      isEmailRequried: yes
      isEmailConfirmationRequired: yes



config.sessionKeys ?= getRandomSessionKeys()

module.exports = config