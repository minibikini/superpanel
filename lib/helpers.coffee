{camelize, titleize, underscore, singularize} = require 'inflecto'

module.exports = helpers =
  copyObject: (input) ->
    output = {}
    output[key] = val for key, val of input
    output

  getCollectionRouteName: (collection, suffix = '') ->
    "collection" + camelize(collection.path) + suffix

  titleizeKey: (key) -> titleize underscore key

  getCollectionDisplayName: (collection) ->
    collection.displayName or helpers.titleizeKey collection.path

  singularCollectionKey: (collection) ->
    collection.singularKey or singularize collection.path