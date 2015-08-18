require('es6-promise').polyfill()
require('isomorphic-fetch')
qs = require('qs')

request = (url, opts = {}) ->
  url += "?" + qs.stringify opts.query if opts.query

  opts.credentials = 'include'
  opts.headers ?= {}
  opts.headers['Accept'] = 'application/json'

  if opts.method in ['POST', 'PUT', 'PATCH'] and opts.body
    opts.headers['Content-Type'] = 'application/json'
    opts.body = JSON.stringify opts.body

  if opts.auth
    opts.headers['Authorization'] = 'Basic ' + btoa opts.auth
    delete opts.auth

  fetch(url, opts)
  .then (response) ->
    if response.status in [200, 201, 202, 204, 0]
      response
    else
      response.json().then (body) ->
        Promise.reject body.error or body or new Error(response.statusText)

  .then (response) -> response.json()

['post', 'put', 'patch'].forEach (key) ->
  method = key.toUpperCase()
  request[key] = (url, body) -> request url, {method, body}

module.exports = request