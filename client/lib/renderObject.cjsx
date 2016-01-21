typeOf = require 'typeof'

{_, moment, formatters, Link} = require '../toolbelt'
{titleizeKey} = require '../../lib/helpers'

module.exports = renderObject = (schema, obj, propName) ->
  output = []

  formatProperty = (key, value) ->
    fieldOpts = _.get(schema, "properties.#{key}") or {}

    _.defaults fieldOpts,
      displayName: titleizeKey key
      type: typeOf value
      path: key
      formatter: fieldOpts.formatter or fieldOpts.type or typeOf value

    {displayName, type, formatter} = fieldOpts

    formatted = if formatter and formatters.get(formatter)
      formatters.get(formatter)(schema, obj, fieldOpts)
    else
      value

    if fieldOpts?.collectionLink and value
      to = "resource#{fieldOpts.collectionLink}Show"
      formatted = <Link to={to} params={{id: value}}>{formatted}</Link>

    <tr key={key}><td><strong>{displayName}</strong></td><td>{formatted}</td></tr>

  propKeys = _.keys _.get(schema, "properties") or {}

  rows = for key in propKeys when not _.isObject(obj[key]) and not _.isArray(obj[key])
    formatProperty key, obj[key]

  rows2 = for key, value of obj when (key not in propKeys) and not _.isObject(value) and not _.isArray(value)
    formatProperty key, value

  output.push <h2 key="header">{schema?.displayName or titleizeKey propName}</h2>

  output.push <table key={Math.random()} className="horizontal striped">
    <tbody>
      {rows.concat rows2}
    </tbody>
  </table>

  for key, value of obj when _.isObject(value) and not _.isEmpty(value)
    propSchema = _.get(schema, "properties.#{key}")
    output.push renderObject propSchema, value, key

  output
