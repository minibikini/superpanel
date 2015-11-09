_ = require 'lodash'
customCommonRequire = require.context __CUSTOM_VIEWS_PATH__
customCommons = customCommonRequire.keys()

customResourceRequire = require.context __CUSTOM_RESOURCES_PATH__, true, /views/
customResources = customResourceRequire.keys()

# TODO: refactor this to work in all scenarios

magicRequire = (name, type = "common", alt) ->
  if type is 'common' and name in customCommons
    return customCommonRequire name
  if type is 'resource' and name in customResources
    return customResourceRequire name

  if alt
    alt
  else
    require '../' + name

magicRequire.withDefaults = (name) ->
  defaultObject = require '../' + name[2..]
  custom = if name in customCommons then customCommonRequire name else {}
  res = _.defaults custom, defaultObject
  res

module.exports = magicRequire