Router = require('react-router')
React = require 'react'

belt =
  React: React
  Router: Router
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
  # Loading: require './views/Loading'
  # errorMessages: require './lib/errorMessages'
  # ContentPage: require './components/ContentPage'
  F: require './components/F'
  helpers: require '../lib/helpers'
  formatters: require '../lib/formatters'
  # cdnUrl: require '../../lib/cdnUrl'
  # PageMixin: require './mixins/PageMixin'
  magicRequire: require './lib/magicRequire'

module.exports = belt