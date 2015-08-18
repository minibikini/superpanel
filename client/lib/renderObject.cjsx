_ = require 'lodash'
{titleizeKey} = require '../../lib/helpers'

module.exports = renderObject = (schema, obj, propName) ->
  output = []

  rows = for key, value of obj when not _.isObject(value) and not _.isArray(value)
    displayName = _.get schema, "properties.#{key}.displayName"
    name = displayName or titleizeKey key
    <tr key={key}><td><strong>{name}</strong></td><td>{value}</td></tr>

  output.push <h2>{schema?.displayName or titleizeKey propName}</h2>

  output.push <table key={Math.random()} className="horizontal striped">
    <tbody>
      {rows}
    </tbody>
  </table>

  for key, value of obj when _.isObject(value) and not _.isEmpty(value)
    propSchema = _.get(schema, "properties.#{key}")
    output.push renderObject propSchema, value, key

  output
