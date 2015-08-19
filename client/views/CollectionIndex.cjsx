{React, Router, Spinner, request, _, moment, Link, config, formatters, F} = require '../toolbelt'
{camelize, titleize, underscore, capitalize} = require 'inflecto'
{deserialize} = require '../../lib/jsonApi'
{RenderForm} = forms = require 'newforms'
{Icon} = F
Table = require 'react-simple-table'
Pager = require 'react-pager'

formatDate = (path, format = 'lll') -> (row) ->
  moment(_.get row, path).format format


opFields =
  [
   ['startsWith', 'Starts With']
   ['match', 'RegExp']
   ['eq', '==']
   ['ne', '!=']
   ['gt', '>']
   ['ge', '>=']
   ['lt', '<']
   ['le', '<=']
 ]


module.exports = (schema) ->
  React.createClass
    mixins: [ Router.State ]
    # displayName: schema.getKeyName() + 'CollectionIndex'
    displayName: 'ResourceCollectionIndex'
    schema: schema
    getInitialState: ->
      {query} = @props
      currentPage = if query.page then query.page - 1 else 0
      meta: null
      isLoading: no
      items: []
      perPage: config.itemsPerPage
      currentPage: currentPage
      visiblePages: 10
      totalPages: 0
      filter: null

    getTitle: -> @schema.getTitle()

    refresh: ->
      @setState isLoading: yes
      @load()

    componentDidMount: -> @refresh()

    # componentWillUpdate: ->

    load: ->
      offset = Math.ceil @state.currentPage * @state.perPage
      query = limit: @state.perPage, offset: offset

      if rels = @schema.getRelations()
        query.include = (rel.name for rel in rels when rel.type is 'belongsTo').join(',')

      if filter = _.clone @state.filter
        if filter.op is 'startsWith'
          filter.op = 'match'
          filter.value = '(?i)^' + filter.value

        # query.filter = {}
        if filter.value
          _.set query, ['filter', filter.field, filter.op], filter.value

      request(@schema.getUrl(), {query}).then (reply) =>
        {meta, data, included} = reply
        totalPages = Math.ceil meta.total / meta.limit
        items = deserialize data, @schema, included
        @setState {meta, items, totalPages, isLoading: no}
      .catch (e) -> console.log e

    handlePageChanged: (newPage) ->
      query = @context.router.getCurrentQuery()
      path = @context.router.getCurrentPathname()
      query.page = newPage + 1
      delete query.page if newPage is 0
      document?.getElementById('content').scrollTop = 0
      @context.router.transitionTo path,  {}, query
      @setState {isLoading: yes, currentPage: newPage}, =>
        @load newPage

    getActionLink: (item, action) ->
      action = {name: action, displayName: titleize(underscore(action))} if _.isString action
      to = @schema.getRouteName capitalize action.name
      <Link className="button" key={to} to={to} params={{id: item.id}}>{action.displayName}</Link>


    getColumns: ->
      fields = @schema.get 'views.index.fields'
      if _.isEmpty fields
        fields = if @state.items.length
          for key, value of @state.items[0] when not _.isArray(value) and not _.isObject(value)
            key
        else []


      fields = for f in fields
        do (f) =>
          f = {displayName: titleize(underscore(f)), path: f} if _.isString f
          f._path ?= f.path

          if fieldSchema = @schema.get "items.properties.#{f.path}"
            if fieldSchema.displayName
              f.displayName = fieldSchema.displayName

            f.function ?= switch fieldSchema.format
              when 'datetime' then formatDate f.path, fieldSchema.dateFormat or 'lll'
              when 'date' then formatDate f.path, fieldSchema.dateFormat or 'll'
              else undefined


          formatter = f.formatter or @schema.getFormatter f.path
          if formatter
            f.function = (row) => formatters.get(formatter)(@schema, row, f)

          if f.link and f.link.type is 'relation' and rel = @schema.getRelation f.link.to
            [to, idPath] = switch rel.type
              when 'hasMany' then [@schema.getRouteName('Show' + rel.name), @schema.getPk()]
              when 'belongsTo' then [rel.getSchema().getRouteName('Show'), "#{rel.name}.#{rel.getSchema().getPk()}"]

            getLinkText = (row, path) =>
              if formatter
                formatters.get(formatter)(@schema, row, f)
              else
                _.get(row, path)

            f.function = (row) =>
              if id = _.get row, idPath
                <Link to={to} params={{id}}>{getLinkText(row, f._path)}</Link>


          delete f.path if f.function?
          f

      if (actions = @schema.get('views.index.actions')) and actions?.length
        fields.push
          function: (row) =>
            @getActionLink row, action for action in actions

      fields


    getPager: ->
      return unless @state.totalPages

      <Pager total={@state.totalPages}
         current={@state.currentPage}

         {# Optional }
         titles={{
             first:   'First',
             prev:    '\u00AB',
             prevSet: '...',
             nextSet: '...',
             next:    '\u00BB',
             last:    'Last'
         }}

         visiblePages={@state.visiblePages}
         onPageChanged={@handlePageChanged}
      />

    componentDidUpdate: ->
      if $table = React.findDOMNode(@refs.table)
        {offsetHeight, offsetWidth} = $table
        offsetHeight = 100 if offsetHeight < 100
        @tableSize =
          width: offsetWidth
          height: offsetHeight

    renderContent: ->
      content = if @state.isLoading then <Spinner {...@tableSize} />
      else if @state.items.length
        <Table ref="table" key="collection-table" className="striped hover" columns={@getColumns()} data={@state.items} />
      else ''

      <div>
        {content}
        {@getPager()}
      </div>


    handleFilterChange: ->
      form = @refs.filterForm.getForm()
      filter = if _.isEmpty(form.data.value) then null else form.data
      @setState {filter, isLoading: yes}, => @load()


    renderFilterForm: ->
      Form = forms.Form.extend
        field: forms.ChoiceField
          choices: @schema.getFields() or []
          label: no
          initial: @schema.getFields()?[0]?[0]
        op: forms.ChoiceField
          choices: opFields
          label: no
          initial: 'startsWith'
        value: forms.CharField label: no, required: no

      form = new Form onChange: @handleFilterChange

      <form onSubmit={@onSubmit}>
        <RenderForm form={form} ref="filterForm" />
      </form>

    render: ->
      buttons = if @schema.get 'views.create'
        <div>
          <Link className="button" to={@schema.getRouteName 'Create'}><Icon name="plus"/> Create</Link>
        </div>

      <div>
        <div className="grid-block">
          <div className="grid-block"><h1>{@getTitle()}</h1></div>
          <div className="grid-block shrink">{buttons}</div>
        </div>
        <div className="list-controls clearfix">
          <div className="float-right">Found: {@state.meta?.total or 0} Items</div>
          <div className="filters">{@renderFilterForm()}</div>
        </div>

        {@renderContent()}
      </div>

