Promise = require 'bluebird'
inflecto = require 'inflecto'
_ = require 'lodash'
r = require './db'

{serialize} = require './jsonApi'


getForeignKey = (relName) -> inflecto.singularize(relName) + 'Id'
getRelationTable = (relName) ->
  r.table inflecto.underscore relName

allowedFilterOperators = ['match', 'eq', 'ne', 'gt', 'ge', 'lt', 'le']

enforceType = (schema, key, value, op) ->
  switch schema.get("items.properties.#{key}.type")
    when 'number' then value *= 1
    when 'string' then value += ''
    when 'boolean'
      value = value not in ['false', '0', 'no', 'off', 'undefined', 'null', undefined]
    else value

getRqlFields = (key) ->
  key = key.split '.'
  res = r.row key[0]
  res = res(k) for k in key[1..]
  res

module.exports = (schema, query) ->
  $table = r.table schema.getTableName()

  limit = Number query.limit or 20
  limit = 300 if limit > 300
  offset = Number query.offset or 0

  {include, index, indexValue, filter, sort} = query

  dbQuery = $table

  if index and indexValue
    dbQuery = dbQuery.getAll indexValue, {index}

  if not sort? and softField = schema.getDefaultOrderBy()
    if not indexValue
      dbQuery = dbQuery.orderBy index: r.desc softField
    else
      sort = '-' + softField

  if filter
    filterChain = r.expr(1).eq(1)

    for key, opVal of filter
      for op, val of opVal
        throw code: 'invalid_filter' unless op in allowedFilterOperators
        if op is 'match' and schema.get("items.properties.#{key}.type") is 'number'
          op = 'eq'
          val = val[5..]

        filterChain = filterChain.and getRqlFields(key)[op](enforceType schema, key, val)

    dbQuery = dbQuery.filter filterChain

  if sort
    orderBy = if sort[0] is '-' then r.desc sort[1...] else r.asc sort
    dbQuery = dbQuery.orderBy orderBy

  dbQuery
  .skip offset
  .limit limit
  .then (records) ->
    dbQuery.count().then (total) ->
      include = include.split(',') if include

      reply = meta: {total, limit, offset, include, sort, filter}
      reply.data = serialize records, schema

      if include
        relatedRecords = []
        relatedIds = {}
        include.forEach (relName) ->
          items = _.compact _.pluck reply.data, ['relationships', relName, 'data']
          relatedRecords.push items if items.length

        relatedRecords = _.unique _.flatten(relatedRecords), (i) -> i.type + i.id

        for relrec in relatedRecords
          relatedIds[relrec.type] ?= []
          relatedIds[relrec.type].push relrec.id

        getIncluded = for table, ids of relatedIds
          do (table, ids) ->
            r.table(table).getAll.apply(r.table(table), ids).then (res) ->
              serialize res, schema.getSchemaFor table

        reply.included = Promise.all(getIncluded).then (res) ->
          _.flatten res

      Promise.props reply