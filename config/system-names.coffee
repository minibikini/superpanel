_ = require 'lodash'
{projectRoot} = require '../lib/program'

try
  config = require "#{projectRoot}/config/system-names"
catch e
  if e.code is 'MODULE_NOT_FOUND'
    config = {}
  else throw e

module.exports = _.defaultsDeep config,
  buildDirName: '_superpanel-build'
  collections:
    users: 'users'
    tokens: 'tokens'
