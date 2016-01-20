{React, Router, Spinner, request, _, moment, Link, config, formatters, findDOMNode} = require '../toolbelt'
{titleize, underscore, capitalize} = require 'inflecto'

Table = require 'react-simple-table'
Pager = require 'react-pager'

formatDate = (path) -> (row) ->
  moment(_.get row, path).format('lll')

module.exports = (schema, relation) ->
  relatedSchema = relation.getSchema()
  relatedViewSchema = schema.get("items.views.related.#{relation.name}") or relatedSchema.get('views.index')


  React.createClass
    mixins: [ Router.State ]
    displayName: schema.getKeyName() + 'CollectionItemRelated'
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

    componentDidMount: -> @refresh()

    getTitle: -> relatedSchema.getDisplayName()

    refresh: ->
      @setState isLoading: yes
      @load()

    getOffset: -> Math.ceil @state.currentPage * @state.perPage

    load: ->
      query = limit: @state.perPage, offset: @getOffset()
      query.include = (rel.name for rel in relatedSchema.getRelations() when rel.type is 'belongsTo').join(',')

      request("/api/collections/#{@schema.getUrlName()}/#{@getParams().id}/#{relation.name}", {query}).then (reply) =>
        {meta, data, included} = reply
        totalPages = Math.ceil meta.total / meta.limit

        items = for item in data
          out = item.attributes or {}
          out[schema.getPk()] = item.id
          if not _.isEmpty(included) and item.relationships
            for name, val of item.relationships
              if relItem = _.find included, val.data
                out[name] = relItem.attributes
                pk = relatedSchema.getRelation(name).getSchema().getPk()
                out[name][pk] = relItem.id
          out

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
      to = relatedSchema.getRouteName capitalize action.name
      <Link className="button" key={to} to={to} params={{id: item.id}}>{action.displayName}</Link>

    getColumns: ->
      fields = relatedViewSchema?.fields
      unless fields
        fields = if @state.items.length
          for key, value of @state.items[0] when not _.isArray(value) and not _.isObject(value)
            {displayName: titleize(underscore(key)), path: key}
        else []

      columns = for f in fields
        do (f) ->
          f = {displayName: titleize(underscore(f)), path: f} if _.isString f
          f._path = f.path

          if fieldSchema = relatedSchema.get "items.properties.#{f.path}"
            f.function ?= switch fieldSchema.format
              when 'datetime' then formatDate(f.path)
              when 'date' then formatDate f.path, fieldSchema.dateFormat or 'll'
              else undefined

          formatter = f.formatter or relatedSchema.getFormatter f.path

          if formatter and formatters.get(formatter)
            f.function = (row) ->
              formatters.get(formatter)(relatedSchema, row, f)

          if f.link and f.link.type is 'relation' and rel = relatedSchema.getRelation f.link.to
            [to, idPath] = switch rel.type
              when 'hasMany' then [relatedSchema.getRouteName('Show' + rel.name), relatedSchema.getPk()]
              when 'belongsTo' then [rel.getSchema().getRouteName('Show'), "#{rel.name}.#{rel.getSchema().getPk()}"]

            getLinkText = (row, path) =>
              if formatter and formatters.get(formatter)
                formatters.get(formatter)(relatedSchema, row, f)
              else
                _.get(row, path)

            f.function = (row) =>
              if id = _.get row, idPath
                <Link to={to} params={{id}}>{getLinkText(row, f._path)}</Link>



          delete f.path if f.function?
          f


      if (actions = relatedViewSchema?.actions) and actions?.length
        columns.push
          function: (row) =>
            @getActionLink row, action for action in actions

      columns


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
      if $table = findDOMNode(@refs.table)
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


    render: ->
      <div>
        <h1>{@getTitle()}</h1>
        {@renderContent()}
      </div>

