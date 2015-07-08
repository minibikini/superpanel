Router = require('koa-router')
koaBody = require('koa-body')()

_ = require 'lodash'
logger = require './logger'
r = require './db'
getIndexRestResponse = require './getIndexRestResponse'

{serialize, deserialize} = require './jsonApi'

showLinks = _.get require('../config/config'), 'api.showLinks'


module.exports = (schema) ->
  router = Router()

  $table = r.table schema.getTableName()

  router.param 'id', (id, next) ->
    @throw 404 unless @record = yield $table.get id
    yield next

  .get '/', ->
    @body = yield getIndexRestResponse schema, @query

  .post '/', koaBody, ->
    {data, included} = @request.body
    # data.createdBy = @user.id
    newRecord = deserialize data, schema, included
    newRecord.createdAt = new Date
    result = yield $table.insert newRecord, returnChanges: yes
    console.log serialize _.get(result, 'changes[0].new_val'), schema
    @body = data: serialize _.get(result, 'changes[0].new_val'), schema
    @status = 201

  #   @body = coupon: yield Coupon.create data

  .get '/:id', ->
    yield []
    data = serialize @record, schema
    @body = {data} or @throw 404

  .delete '/:id', ->
    @throw 404 unless @isAdmin
    # data = yield Order.getWithRelated(@params.id)

    yield $table.get(@params.id).detele()
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
          items = yield r.table(rel.getSchema().getTableName()).getAll @record[rel.ownKey], index: rel.getIndex()
          @body = data: serialize items[0], rel.getSchema()

        router.get "/:id/relationships/#{rel.name}", ->
          yield []
          @body = data:
            type: rel.resource
            id: @record[rel.ownKey]


  router.routes()