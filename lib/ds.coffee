# modelDynamic =
#   name: 'user'
#   methods: {}
#   computed: {}
#   hooks: {afterCreate, beforeValidate, beforeDestroy, }



config = require '../config/config'
DSRethinkDbAdapter = require('js-data-rethinkdb')
JSData = require('js-data')
models = {}

rethinkdbAdapter = new DSRethinkDbAdapter config.rethinkdb
  # host: config.API_DB_HOST,
  # port: config.API_DB_PORT,
  # db: config.API_DB_DATABASE,
  # authKey: config.API_DB_AUTH_KEY,
  # min: 10,
  # max: 50


# Here we turn off a bunch of features we don't necessarily
# need on the server to maximize performance and avoid other
# issues
store = new JSData.DS
  # cacheResponse: off
  # notify: off
  # upsert: off
  keepChangeHistory: off
  resetHistoryOnInject: off
  ignoreMissing: yes
  bypassCache: yes
  findInverseLinks: off
  findHasMany: off
  findBelongsTo: off
  findHasOne: off
  log: off

store.registerAdapter 'rethinkdb', rethinkdbAdapter, default: yes

module.exports =
  store: store
  initModel: (resource) ->
    models[resource.get('path')] = store.defineResource
      # string  Required. The name of the new resource.
      name: resource.get('path')
      # object  See Relations.
      relations: resource.get('relations')

      # string  The name of the field to use as the primary key for instances of this resource. Computed properties are supported as ids. Default: "id".
      idAttribute: resource.getPk()

      # string  Override the default basePath for this resource. Default: DS#defaults.basePath
      # basePath:

      # string  Override the default endpoint for this resource. Default: name.
      # endpoint:

      # boolean Whether to use a wrapper class created from the ProperCase name of the resource. Must be true for computed properties and instance methods to work. Default: true.
      # useClass:

      # boolean Whether to keep a history of changes for items in the data store. Default: false.
      # keepChangeHistory:

      # boolean Whether to reset the history of changes for items when they are injected or re-injected into the data store. This will also reset an item's previous attributes. Default: true.
      # resetHistoryOnInject:

      # function  Override the filtering used internally by DS.filter with your own function here. Default: See the source code.
      # defaultFilter:

      # object  Put anything you want here. It will never be used by the API.
      # meta:

      # object  See Instance Methods (Custom instance behavior).
      # methods:

      # object  See Computed Properties.
      # computed:


      # Model Lifecycle Hooks
      # beforeValidate  function  See Model Lifecycle Hooks.
      # validate  function  See Model Lifecycle Hooks.
      # afterValidate function  See Model Lifecycle Hooks.
      # beforeCreate  function  See Model Lifecycle Hooks.
      # afterCreate function  See Model Lifecycle Hooks.
      # beforeUpdate  function  See Model Lifecycle Hooks.
      # afterUpdate function  See Model Lifecycle Hooks.
      # beforeDestroy function  See Model Lifecycle Hooks.
      # afterDestroy  function  See Model Lifecycle Hooks.
      # beforeInject  function  See Model Lifecycle Hooks.
      # afterInject function  See Model Lifecycle Hooks.


  getModel: (modelName) ->
    models[modelName]
