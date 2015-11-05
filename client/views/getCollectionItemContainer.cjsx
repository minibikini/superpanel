{React, Router, Link, RouteHandler} = require '../toolbelt'

module.exports = (schema) ->
  React.createClass
    mixins: [ Router.State ]
    displayName: schema.getKeyName() + 'ItemContainer'
    schema: schema

    getSections: ->
      return unless rels = @schema.getRelations()
      sections = for rel in rels when rel.type is 'hasMany'
        relRouteName = schema.getRouteName 'Show' + rel.name
        <li key={relRouteName}><Link to={relRouteName} params={@getParams()}>{rel.getTitle()}</Link></li>

      activeCls = if @getRoutes()[3].isDefault then 'active' else ''
      <ul className="condense menu-bar primary">
        <li key="x"><Link to={schema.getRouteName 'Show'} activeClassName={activeCls} params={@getParams()}>Details</Link></li>
        {sections}
      </ul>

    render: ->
      <div style={{width: "100%"}}>
        {@getSections()}
        <RouteHandler />
      </div>

