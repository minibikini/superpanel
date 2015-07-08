_ = require 'lodash'

module.exports = superschema = (input) ->
  input.items = type: input.items if _.isString input.items

  if input.properties?
    for key, val of input.properties when _.isString val
      input.properties[key] = type: val

  for key, val of input when _.isObject val
    input[key] = superschema val

  input
