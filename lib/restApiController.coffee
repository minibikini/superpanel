_ = require 'lodash'
Router = require('koa-router')
koaBody = require('koa-body')()
logger = require './logger'
{store} = require './ds'
getIndexRestResponse = require './getIndexRestResponse'
{serialize, deserialize} = require './jsonApi'
showLinks = _.get require('../config/config'), 'api.showLinks'

module.exports = (schema) ->
  router = Router()
  modelName = schema.getName()

  updateItem = ->
    {data, included} = @request.body
    update = deserialize data, schema, included
    result = yield store.update modelName, @params.id, update
    @body = data: serialize result, schema

  router.param 'id', (id, next) ->
    @throw 404 unless @record = yield store.find modelName, id
    yield next

  .get '/', ->
    @body = yield getIndexRestResponse schema, @query

  .post '/', koaBody, ->
    {data, included} = @request.body
    newRecord = deserialize data, schema, included
    newRecord.createdAt = new Date
    result = yield store.create modelName, @params.id, newRecord
    @body = data: serialize result, schema
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

    yield store.destroy modelName, id
    @body = {}
    @body[schema.getSingularKey()] = null

  schema.getRelations().forEach (rel) ->
    switch rel.type
      when 'hasMany'
        router.get "/:id/#{rel.name}", ->
          @query.index = rel.foreignKey
          @query.indexValue = @params.id
          @body = yield getIndexRestResponse rel.getSchema(), @query

      when 'belongsTo'
        router.get "/:id/#{rel.name}", ->
          # doesn't work :(
          # record = yield store.loadRelations modelName, @record, [rel.resource]

          record = yield store.find modelName, @params.id, with: [rel.resource]

          @body = data: serialize record[rel.name], rel.getSchema()

        router.get "/:id/relationships/#{rel.name}", ->
          yield []
          @body = data:
            type: rel.resource
            id: @record[rel.ownKey]


  router.routes()