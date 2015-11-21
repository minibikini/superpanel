{React, Router, Spinner, request, _, moment, helpers, Link, magicRequire} = require '../toolbelt'

EmptyDiv = require '../components/EmptyDiv'

formatDate = (path) -> (row) ->
  moment(_.get row, path).format('lll')

renderObject = require '../lib/renderObject'

module.exports = (schema) ->
  CollectionItemTop = magicRequire.mayBe "./#{schema.getTableName()}/views/CollectionItemTop", 'resource', EmptyDiv

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
      @load()

    getApiUrl: ->
      "/api/collections/#{@schema.getUrlName()}/#{@state.id}"

    load: ->
      @setState isLoading: yes
      request(@getApiUrl()).then (reply) =>
        item = reply.data.attributes
        item[@schema.getPk()] = reply.data.id
        @setState {item, isLoading: no}
      .catch (e) ->
        console.log e, e.stack

    getContent: ->
      renderObject @schema.get('items'), @state.item, @schema.getSingularKey()

    updateState: (state) ->
      @setState state

    render: ->
      return <Spinner /> if @state.isLoading

      <div>
        <CollectionItemTop id={@state.id} schema={@schema} updateState={@updateState} item={@state.item} />
        {@getContent()}
      </div>

