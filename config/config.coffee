_ = require 'lodash'
{projectRoot} = require '../lib/program'

try
  config = require "#{projectRoot}/config/config"
catch e
  if e.code is 'MODULE_NOT_FOUND'
    config = {}
  else throw e

module.exports = _.defaultsDeep config,
  name: 'superpanel'
  timezone: '+07:00'
  currency: 'USD'
  port: 1337

  rethinkdb:
    db: 'superpanel'

  # api:
  #   showLinks: yes

  uiUrl: '/area51'

  auth:
    isOpenSignup: no
    local:
      usernameField: 'email'
      isEmailRequried: yes
      isEmailConfirmationRequired: yes
