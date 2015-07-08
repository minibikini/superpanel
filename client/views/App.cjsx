{React, RouteHandler} = require '../toolbelt'
Sidebar = require '../components/Sidebar'

module.exports = React.createClass
  displayName: 'AppView'
  render: ->
    <div className="grid-frame">
      <div className="grid-block shrink" id="sidebar">
        <Sidebar />
      </div>
      <div className="grid-block content-block" id="content">
        <RouteHandler />
      </div>
    </div>