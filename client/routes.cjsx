{Route, DefaultRoute, Router, helpers, RouteHandler, magicRequire} = require './toolbelt'

config = _config or {}
ResourceSchema = require '../lib/ResourceSchema'
CollectionIndex = require './views/CollectionIndex'
DefaultCollectionItem = require './views/CollectionItem'
getCollectionItemRelated = require './views/getCollectionItemRelated'
getCollectionItemContainer = require './views/getCollectionItemContainer'
getCreateItemView = require './views/getCreateItemView'

collectionRoutes = []

RouteHandlerContainer = React.createClass
  displayName: 'RouteHandlerContainer'
  render: ->
    <RouteHandler />

config.resources.forEach (resource) ->
  return if resource.disableUi
  resource = new ResourceSchema config.resources, resource
  name = resource.getRouteName 'Index'
  nameItem = resource.getRouteName 'Show'
  relatedRoutes = []
  relations = resource.getRelations()
  CollectionItem = magicRequire "./#{resource.getTableName()}/views/CollectionItem", 'resource', DefaultCollectionItem

  createRoute = if resource.get('views.create')
    routeName = resource.getRouteName 'Create'
    <Route key={routeName} name={routeName} path='create' handler={getCreateItemView resource } />

  relatedRoutes = for rel in relations when rel.type is 'hasMany'
    relRouteName = resource.getRouteName 'Show' + rel.name
    <Route key={rel.getKey()} name={relRouteName} path={rel.name} handler={getCollectionItemRelated resource, rel} />

  collectionRoutes.push <Route key={name} name={name} path={'collections/' + resource.getUrlName()} handler={RouteHandlerContainer} >
    <DefaultRoute handler={CollectionIndex resource} />
    {createRoute}
    <Route key={nameItem} name={nameItem} path=":id" handler={getCollectionItemContainer resource}>
      <DefaultRoute handler={CollectionItem resource} />
      {relatedRoutes}
    </Route>
  </Route>

module.exports =
  <Route name="app" path="/" handler={require './views/App'}>
    <DefaultRoute handler={magicRequire './views/Dashboard'} />
    {collectionRoutes}
    {# <Route name="faq" handler={require './views/FAQ'} />}
    {# <Router.NotFoundRoute handler={require './views/NotFound'}/>}
  </Route>
