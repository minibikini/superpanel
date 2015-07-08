{React, Router, Spinner, request, _, moment, helpers, Link} = require '../toolbelt'
{titleizeKey, singularCollectionKey, getCollectionRouteName} = helpers
{camelize, titleize, underscore, capitalize} = require 'inflecto'

formatDate = (path) -> (row) ->
  moment(_.get row, path).format('lll')

renderObject = (schema, obj, propName) ->
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

module.exports = (schema) ->
  React.createClass
    mixins: [ Router.State ]
    displayName: schema.getKeyName() + 'ItemShow'
    schema: schema
    contextTypes:
      router: React.PropTypes.func

    getInitialState: ->
      query = @context.router.getCurrentParams()
      id: query.id or null
      isLoading: no

    componentWillMount: ->
      @setState isLoading: yes
      @load()

    load: ->
      request("/api/collections/#{@schema.getUrlName()}/#{@state.id}").then (reply) =>
        item = reply.data.attributes
        item[@schema.getPk()] = reply.data.id
        @setState {item, isLoading: no}
      .catch (e) ->
        console.log e

    getContent: ->
      renderObject @schema.get('items'), @state.item, @schema.getSingularKey()

    render: ->
      # console.log @getPath(), @getPathname(), @getParams()
      return <Spinner /> if @state.isLoading
      <div>
        {@getContent()}
      </div>

