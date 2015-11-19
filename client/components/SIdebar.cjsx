{React, Link, F, helpers} = require '../toolbelt'
{Icon} = F
config = _config or {}
ResourceSchema = require '../../lib/ResourceSchema'

module.exports = React.createClass
  className: "Sidebar"
  render: ->
    collectionLinks = for collection in config.resources when not collection.disableUi
      collection = new ResourceSchema config.resources, collection
      to = collection.getRouteName 'Index'
      <li key={to}><Link to={to}>{collection.getDisplayName()}</Link></li>

    <ul className="menu-bar icon-left primary condense vertical">
      <li><Link to='/'>Dashboard</Link></li>
      {collectionLinks}
      <li><hr /></li>
      <li><a href="/logout">Logout</a></li>
    </ul>



