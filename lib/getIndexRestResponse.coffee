Promise = require 'bluebird'
inflecto = require 'inflecto'
_ = require 'lodash'
r = require './db'
{store} = require './ds'

{serialize} = require './jsonApi'

getForeignKey = (relName) -> inflecto.singularize(relName) + 'Id'

getRelationTable = (relName) ->
  r.table inflecto.underscore relName

allowedFilterOperators = ['match', 'eq', 'ne', 'gt', 'ge', 'lt', 'le']

enforceType = (schema, key, value) ->
  switch schema.get("items.properties.#{key}.type")
    when 'number' then value *= 1
    when 'string' then value += ''
    when 'boolean'
      value = value not in ['false', '0', 'no', 'off', 'undefined', 'null', undefined]
    else value


module.exports = (schema, query) ->
  modelName = schema.getName()

  limit = Number query.limit or 20
  limit = 300 if limit > 300
  offset = Number query.offset or 0

  {include, index, indexValue, filter, sort} = query
  sort ?= '-createdAt'

  orderBy = for field in sort.split(',')
    if field[0] is '-'
      [field[1..], 'DESC']
    else
      [field, 'ASC']

  params = {where: filter, limit, offset, orderBy}

  if include
    withRels = for name in include.split(',')
      schema.getRelation(name).resource

  store.findAll(modelName, params, {with: withRels}).then (records) ->
    include = include.split(',') if include
    total = null

    reply = meta: {total, limit, offset, include, sort, filter}

    relatedRecords = []
    relatedIds = {}

    for record in records
      for relKey in schema.getRelationKeys() when record[relKey]?
        if relKey in include
          relResource = schema.getRelation(relKey).resource
          relSchema = schema.getSchemaFor relResource
          relPk = relSchema.getPk()
          relatedIds[relResource] ?= []
          if record[relKey][relPk] not in relatedIds[relResource]
            relatedIds[relResource].push record[relKey][relPk]
            relatedRecords.push serialize record[relKey], schema.getSchemaFor relResource

        delete record[relKey]


    reply.data = serialize records, schema
    reply.included = relatedRecords if include
    reply