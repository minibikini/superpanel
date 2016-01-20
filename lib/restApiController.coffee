_ = require 'lodash'
Router = require('koa-router')
koaBody = require('koa-body')()
logger = require './logger'
r = require './db'
getIndexRestResponse = require './getIndexRestResponse'
{serialize, deserialize} = require './jsonApi'
showLinks = _.get require('../config/config'), 'api.showLinks'

module.exports = (schema) ->
  router = Router()
  $table = r.table schema.getTableName()

  updateItem = ->
    {data, included} = @request.body
    update = deserialize data, schema, included
    result = yield $table.get(@params.id).update(update, returnChanges: yes).run()
    @body = data: serialize _.get(result, 'changes[0].new_val'), schema

  router.param 'id', (id, next) ->
    @throw 404 unless @record = yield $table.get id
    yield next

  .get '/', ->
    @body = yield getIndexRestResponse schema, @query

  .post '/', koaBody, ->
    {data, included} = @request.body
    newRecord = deserialize data, schema, included
    newRecord.createdAt = new Date
    result = yield $table.insert newRecord, returnChanges: yes
    @body = data: serialize _.get(result, 'changes[0].new_val'), schema
    @status = 201

  .get '/:id', ->
    yield []
    data = serialize @record, schema
    @body = {data} or @throw 404

  .patch '/:id', koaBody, updateItem # jsonapi
  .post '/:id', koaBody, updateItem
  .put '/:id', koaBody, updateItem

  .delete '/:id', ->
    @throw 404 unless @isAdmin

    yield $table.get(@params.id).detele()
    @body = {}
    @body[schema.getSingularKey()] = null

  schema.getRelations().forEach (rel) ->
    switch rel.type
      when 'hasMany'
        router.get "/:id/#{rel.name}", ->
          if rel.via?
            @query = Object.assign @query,
              indexValue: yield r.table(rel.via).getAll(@record[rel.ownKey], index: rel.viaKey)(rel.foreignKey)
              index: rel.getSchema().getPk()
          else
            @query.index = rel.foreignKey
            @query.indexValue = @params.id

          @body = yield getIndexRestResponse rel.getSchema(), @query, rel

      when 'belongsTo'
        router.get "/:id/#{rel.name}", ->
          items = yield r.table(rel.getSchema().getTableName()).getAll @record[rel.ownKey], index: rel.getIndex()
          @body = data: serialize items[0], rel.getSchema()

        router.get "/:id/relationships/#{rel.name}", ->
          yield []
          @body = data:
            type: rel.resource
            id: @record[rel.ownKey]


  router.routes()