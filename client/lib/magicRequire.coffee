_ = require 'lodash'
customCommonRequire = require.context __CUSTOM_VIEWS_PATH__
customCommons = customCommonRequire.keys()

customResourceRequire = require.context __CUSTOM_RESOURCES_PATH__, true, /views/
customResources = customResourceRequire.keys()

module.exports = (name, type = "common", alt) ->
  if type is 'common' and name in customCommons
    return customCommonRequire name
  if type is 'resource' and name in customResources
    return customResourceRequire name

  if alt
    alt
  else
    require '../' + name
