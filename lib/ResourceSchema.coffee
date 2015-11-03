_ = require 'lodash'
{camelize, singularize, titleize, underscore, camelizeBig} = require 'inflecto'
assert = require('assert')

class ResourceRelation
  _fullSchema: null
  _schema: null

  constructor: (rel, @_fullSchema) ->
    if _.isArray(rel)
      [@type, @resource, @name, @ownKey, @foreignKey, @index] = rel
    else
      {@type, @resource, @name, @ownKey, @foreignKey, @index} = rel

  getSchema: ->
    @_schema or @_schema = new ResourceSchema @_fullSchema, _.find @_fullSchema, path: @resource
  getIndex: -> @index or @foreignKey
  getKey: -> [@type, @resource, @name, @ownKey, @foreignKey, @index].join()
  getTitle: -> titleize underscore @name


module.exports = class ResourceSchema
  constructor: (@fullSchema, @_schema, @prefix = "/api/collections") ->
    # assert.notEqual @fullSchema
    # assert.notEqual @_schema

  getName: ->
    @_schema.name or @_schema.path

  getUrlName: ->
    @_schema.urlName or @_schema.path

  getJsonApiType: ->
    @get('jsonApiType') or @get('path')

  getUrl: ->
    "#{@prefix}/#{@getUrlName()}"

  get: (path) ->
    _.get @_schema, path

  getApiType: ->
    @_schema.path

  getTableName: ->
    @_schema.tableName or @_schema.path

  getSingularKey: ->
    @_schema.singularKey or camelize singularize @_schema.path

  getRelations: ->
    @_rels ?= for rel in @get('items.relations') or []
      new ResourceRelation rel, @fullSchema

  getRelationKeys: ->
    @_relKeys ?= (rel.name for rel in @getRelations())

  getRelation: (name) ->
    _.find @getRelations(), {name}

  hasRelations: ->
    not _.isEmpty @get 'items.relations'

  getPk: ->
    @_schema.primaryKey or "id"

  getSchemaFor: (path) ->
    new ResourceSchema @fullSchema, _.find @fullSchema, {path}

  getRouteName: (suffix = '') ->
    "resource" + camelize(@getTableName()) + suffix

  getDisplayName: ->
    @get('displayName') or titleize underscore @getTableName()

  getTitle: ->
    @get('title') or @getDisplayName()

  getKeyName: ->
    camelizeBig @getTableName()

  getFormatter: (path) ->
    path = path?.replace(/\./g, ".properties.")
    @get "items.properties.#{path}.formatter"

  getFields: ->
    if props = @get('items.properties')
      for key, {displayName} of props
        value: key, label: displayName or titleize underscore key
    else []