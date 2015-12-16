typeOf = require 'typeof'

{_, moment, formatters} = require '../toolbelt'
{titleizeKey} = require '../../lib/helpers'

module.exports = renderObject = (schema, obj, propName) ->
  output = []

  rows = for key, value of obj when not _.isObject(value) and not _.isArray(value)
    do (key, value) ->
      if fieldOpts = _.get schema, "properties.#{key}"
        {displayName, type, formatter} = fieldOpts

      displayName ?= titleizeKey key
      type ?= typeOf value

      value = if formatter
        formatters.get(formatter)(schema, value, fieldOpts)
      else
        switch type
          when 'string'
            if _.isEmpty(value) then <span style={color:'#666'}>N/A</span> else value
          when 'boolean'
            if value then <span className="boolean-value-true">&#10004;</span> else <span>&#10060;</span>
          when 'datetime'
            moment(value).format fieldOpts.displayFormat or 'llll'
          when 'null'
            <span style={color:'#666'}>null</span>
          else
            value

      <tr key={key}><td><strong>{displayName}</strong></td><td>{value}</td></tr>

  output.push <h2 key="header">{schema?.displayName or titleizeKey propName}</h2>

  output.push <table key={Math.random()} className="horizontal striped">
    <tbody>
      {rows}
    </tbody>
  </table>

  for key, value of obj when _.isObject(value) and not _.isEmpty(value)
    propSchema = _.get(schema, "properties.#{key}")
    output.push renderObject propSchema, value, key

  output
