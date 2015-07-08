_ = require 'lodash'

showLinks = _.get require('../config/config'), 'api.showLinks'

serialize = (input, schema) ->
  return {} unless input
  return (serialize i, schema for i in input) if _.isArray input
  relationships = undefined
  omitFields = [schema.getPk()]

  links = self: "/#{schema.getUrlName()}/#{input[schema.getPk()]}"  if showLinks

  if schema.hasRelations()
    for rel in schema.getRelations() when rel.type is 'belongsTo' and input[rel.ownKey]
      relationships ?= {}
      omitFields.push rel.ownKey
      relLinks = self: "#{links.self}/relationships/#{rel.name}", related: "#{links.self}/#{rel.name}"  if showLinks

      relationships[rel.name] =
        links: relLinks
        data:
          type: rel.resource
          id: input[rel.ownKey]

  type: schema.getJsonApiType()
  id: input[schema.getPk()]
  attributes: _.omit input, omitFields
  relationships: relationships
  links: links


deserialize = (input, schema, included) ->
  return {} unless input
  return (deserialize i, schema, included for i in input) if _.isArray input

  out = input.attributes or {}
  out[schema.getPk()] = input.id
  if not _.isEmpty(included) and input.relationships
    for name, val of input.relationships
      if relItem = _.find included, val.data
        out[name] = relItem.attributes
        pk = schema.getRelation(name).getSchema().getPk()
        out[name][pk] = relItem.id
  out


module.exports = {serialize, deserialize}