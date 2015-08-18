{React, Router, Spinner, request, _, moment, helpers, Link} = require '../toolbelt'
# {titleizeKey} = helpers

formatDate = (path) -> (row) ->
  moment(_.get row, path).format('lll')

renderObject = require '../lib/renderObject'

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
      return <Spinner /> if @state.isLoading
      <div>
        {@getContent()}
      </div>

