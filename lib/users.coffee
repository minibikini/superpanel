r = require './db'
_ = require 'lodash'

config = require '../config/config'
systemNames = require '../config/system-names'

$table = r.table(systemNames.collections.users)

randomString = (possible, len = 6)->
  text = ''
  for i in [1..len]
    text += possible.charAt(Math.floor(Math.random() * possible.length))
  text

getSolt = (len = 6) ->
  possible = "_!@#$%^&*~.,?|ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  randomString possible, len

hash = (str) ->
  require('crypto').createHash('sha256').update(str).digest("hex")

hashPassword = (pwd, solt) ->
  solt ?= getSolt()
  password = hash pwd + solt
  {password, solt}

validatePassword = (user, password) ->
  return no if _.isEmpty user.password
  hashed = hashPassword(password, user.solt)
  hashed.password is user.password

get = (id) -> $table.get id

getBy = (key, index) ->
  $table.getAll(key, {index}).then ([record]) -> record

getByUsername = (name) ->
  getBy name, config.auth.local.usernameField

getByEmail = (email) ->
  $table.getAll(email, index: 'email').then ([user]) -> user

create = (data) ->
  data.createdAt = r.now()

  $table.insert(data, {returnChanges: yes}).then (reply) ->
    reply.changes[0].new_val

updatePassword = (id, password) ->
  get(id).update hashPassword password

module.exports = {get, getByUsername, validatePassword, getByEmail, create, updatePassword}