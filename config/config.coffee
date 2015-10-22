_ = require 'lodash'
{projectRoot} = require '../lib/program'

try
  config = require "#{projectRoot}/config/config"
catch e
  if e.code is 'MODULE_NOT_FOUND'
    config = {}
  else throw e

module.exports = _.defaults config,
  name: 'superpanel'
  timezone: '+07:00'
  currency: 'USD'

  web:
    port: 1337

  rethinkdb:
    db: 'mobiletopup'

  # api:
  #   showLinks: yes
