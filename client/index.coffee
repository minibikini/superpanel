request = require './request'
window?.React = require 'react'
ReactDOM = require 'react-dom'

require('../scss/app.scss')

startApp = ->
  request('/api/_config')
  .catch (e) ->
    console.error 'request config error', e
  .then (config) ->
    window?._config = config
    Router = require 'react-router'
    routes = require './routes'

    Router.run routes, (Handler, state) ->
      Handler.setTitle = (pageTitle) -> document.title = pageTitle
      node = React.createElement(Handler)

      ReactDOM.render node, document.getElementById('superpanel-app-container')
  .catch (e) ->
    console.error e

showLogin = ->
  Login = React.createElement require('./views/Login'), onLogin: (user) ->
    startApp()

  ReactDOM.render Login, document.getElementById('superpanel-app-container')

if _superpanel_user then startApp() else showLogin()