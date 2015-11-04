request = require './request'

require('../scss/app.scss')

request('/api/_config').then (config) ->
  window?._config = config
  {React, Router, request, ReactDOM} = require './toolbelt'
  window?.React = React

  routes = require './routes'

  Router.run routes, (Handler, state) ->
    Handler.setTitle = (pageTitle) -> document.title = pageTitle
    node = React.createElement(Handler)

    ReactDOM.render node, document.getElementById('superpanel-app-container')
.catch (e) ->
  console.error e