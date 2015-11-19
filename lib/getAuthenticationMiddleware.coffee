_ = require 'lodash'
{projectRoot} = require '../lib/program'
glob = require 'glob'

strategies = {}

loadStrategies = (path) ->
  for file in glob.sync("**/*", cwd: path)
    name = file.split('.')[0]
    strategies[name] ?=
      name: name
      authenticate: require path + '/' + file

getStrategies = (names) ->
  for name in names
    strategies[name] or throw new Error "Auth Strategy `#{name}` is not found"

loadStrategies "#{projectRoot}/lib/authStrategies"
loadStrategies __dirname + "/authStrategies"

try
  policies = require "#{projectRoot}/config/policies"
catch e
  if e.code is 'MODULE_NOT_FOUND'
    policies = []
  else throw e

policies = policies.concat require '../config/policies'

policies = for policy in policies
  if policy.strategies?
    policy.strategies = getStrategies policy.strategies

  policy


module.exports = require('koa-police')(
  defaultStrategies: getStrategies ['isUser']
  policies: policies
)
