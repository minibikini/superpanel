Router = require('react-router')
React = require 'react'
ReactDOM = require('react-dom')

magicRequire = require './lib/magicRequire'

belt =
  React: React
  Router: Router
  ReactDOM: ReactDOM
  findDOMNode: ReactDOM.findDOMNode
  DefaultRoute: Router.DefaultRoute
  Link: Router.Link
  Route: Router.Route
  RouteHandler: Router.RouteHandler
  PureRenderMixin: {}
  request: require './request'
  _: require 'lodash'
  config: require '../config/config-browser'
  cx: require 'classnames'
  moment: require 'moment'
  Spinner: require './components/Spinner'
  F: require './components/F'
  helpers: require '../lib/helpers'
  formatters: magicRequire.withDefaults './lib/formatters'
  magicRequire: magicRequire

module.exports = belt