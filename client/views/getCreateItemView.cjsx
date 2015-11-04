{React, Router, Spinner, request, _, moment, helpers, Link, F} = require '../toolbelt'
{titleizeKey, singularCollectionKey, getCollectionRouteName} = helpers
{camelize, titleize, underscore, capitalize} = require 'inflecto'
{Icon} = F
{serialize} = require '../../lib/jsonApi'

{Form} = require('formsy-react')
{Select, Input} = require 'formsy-react-components'

module.exports = (schema) ->
  React.createClass
    mixins: [ Router.Navigation ]
    displayName: schema.getKeyName() + 'CreateItem'
    schema: schema

    getInitialState: ->
      isLoading: no

    onSubmit: (data) ->
      @setState isLoading: yes
      request.post(@schema.getUrl(), data: serialize(data, @schema)).then (reply) =>
        @transitionTo @schema.getRouteName('Show'), id: reply.data?.id

    getTitle: ->
      if displayName = @schema.get('views.create.displayName')
        displayName
      else if displayName = @schema.get('items.displayName')
        "New #{displayName}"
      else
        "New Item"

    getSubmitButtonTitle: ->
      @schema.get('views.create.submitButtonTitle') or "Create " + @getTitle()

    getInputs: ->
      for key, {type, opts} of @schema.get 'views.create.fields'
        <Input key={key} name={key} type={type} label={opts.label or titleize underscore key} value={opts.initial}/>

    render: ->
      return <Spinner /> if @state.isLoading

      <div>
        <h2>{@getTitle()}</h2>
        <Form onSubmit={@onSubmit}>
          {@getInputs()}
          <button className="button" type="submit"> <Icon name="plus"/> {@getSubmitButtonTitle()}</button>
        </Form>
      </div>
