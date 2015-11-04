{React, Router, Spinner, request, _, moment, Link, config, formatters, F, findDOMNode} = require '../toolbelt'
{camelize, titleize, underscore, capitalize} = require 'inflecto'
{deserialize} = require '../../lib/jsonApi'

CollectionIndexFilterForm = require '../components/CollectionIndexFilterForm'
CollectionIndexPager = require '../components/CollectionIndexPager'

{Icon} = F
Table = require 'react-simple-table'

formatDate = (path, format = 'lll') -> (row) ->
  moment(_.get row, path).format format

module.exports = (schema) ->
  React.createClass
    mixins: [ Router.State ]
    displayName: 'ResourceCollectionIndex'
    schema: schema
    getTitle: -> @schema.getTitle()
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
      filter: query.filter or {value:''}

    componentDidMount: ->
      @setState isLoading: yes
      @load()

    load: ->
      offset = Math.ceil @state.currentPage * @state.perPage
      query = limit: @state.perPage, offset: offset

      if rels = @schema.getRelations()
        query.include = (rel.name for rel in rels when rel.type is 'belongsTo').join(',')

      if filter = _.clone @state.filter
        if filter.op is 'startsWith'
          filter.op = 'match'
          filter.value = '(?i)^' + filter.value

        if filter.value
          _.set query, ['filter', filter.field, filter.op], filter.value

      request(@schema.getUrl(), {query}).then (reply) =>
        {meta, data, included} = reply
        totalPages = Math.ceil meta.total / meta.limit
        items = deserialize data, @schema, included
        @setState {meta, items, totalPages, isLoading: no}
      .catch (e) ->
        console.error e

    handlePageChanged: (newPage) ->
      query = @context.router.getCurrentQuery()
      path = @context.router.getCurrentPathname()
      query.page = newPage + 1
      delete query.page if newPage is 0
      document?.getElementById('content').scrollTop = 0
      @context.router.transitionTo path,  {}, query
      @setState {isLoading: yes, currentPage: newPage}, =>
        @load newPage

    updateFilter: (filter) ->
      @setState {filter}

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

          #  link to filter
          if f.link and f.link.type is 'filter'
            f.link.to ?= @context.router.getCurrentPathname()
            f.link.displayLabelPath ?= f._path

            getLinkText = (row, path) =>
              if formatter
                formatters.get(formatter)(@schema, row, f)
              else
                _.get(row, path)

            f.function = (row) =>
              filter = _.defaults {}, f.link.filter, value: _.get(row, f._path)

              if f.link.to is @context.router.getCurrentPathname()
                <Link to={f.link.to} onClick={@updateFilter.bind(@, filter)} query={{filter}}>{getLinkText(row, f.link.displayLabelPath)}</Link>
              else
                <Link to={f.link.to} query={{filter}}>{getLinkText(row, f.link.displayLabelPath)}</Link>

          delete f.path if f.function?
          f

      if (actions = @schema.get('views.index.actions')) and actions?.length
        fields.push
          function: (row) =>
            @getActionLink row, action for action in actions

      fields

    componentDidUpdate: ->
      if $table = findDOMNode(@refs.table)
        {offsetHeight, offsetWidth} = $table
        offsetHeight = 100 if offsetHeight < 100
        @tableSize =
          width: offsetWidth
          height: offsetHeight

    resetFilter: ->
      path = @context.router.getCurrentPathname()
      query = @context.router.getCurrentQuery()
      delete query.page
      delete query.filter
      @context.router.transitionTo path, {}, query
      @setState {filter: {value:''}, currentPage: 0, totalPages: 0, isLoading: yes}, =>
        @load()

    handleFilterChange: (filter) ->
      path = @context.router.getCurrentPathname()
      query = @context.router.getCurrentQuery()
      delete query.page

      if filter.value is ''
        delete query.filter
      else
        query.filter = filter

      @context.router.transitionTo path,  {}, query
      @setState {filter, currentPage: 0, totalPages: 0, isLoading: yes}, => @load()

    render: ->
      buttons = if @schema.get 'views.create'
        <div>
          <Link className="button" to={@schema.getRouteName 'Create'}><Icon name="plus"/> Create</Link>
        </div>

      content = if @state.isLoading then <Spinner {...@tableSize} />
      else if @state.items.length
        <Table ref="table" key="collection-table" className="striped hover" columns={@getColumns()} data={@state.items} />
      else ''

      <div>
        <div className="grid-block">
          <div className="grid-block"><h1>{@getTitle()}</h1></div>
          <div className="grid-block shrink">{buttons}</div>
        </div>
        <div className="list-controls clearfix">
          <div className="float-right">Found: {@state.meta?.total or 0} Items</div>
          <div className="filters">
            <CollectionIndexFilterForm filter={@state.filter} schema={@schema} onChange={@handleFilterChange} />
            <button className="button" onClick={@resetFilter}>Reset</button></div>
        </div>

        {content}

        <CollectionIndexPager
          totalPages={@state.totalPages}
          currentPage={@state.currentPage}
          visiblePages={@state.visiblePages}
          onChange={@handlePageChanged}
        />
      </div>