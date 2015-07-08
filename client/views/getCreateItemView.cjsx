{React, Router, Spinner, request, _, moment, helpers, Link, F} = require '../toolbelt'
{titleizeKey, singularCollectionKey, getCollectionRouteName} = helpers
{camelize, titleize, underscore, capitalize} = require 'inflecto'
{Icon} = F
{serialize} = require '../../lib/jsonApi'
{RenderForm} = forms = require 'newforms'

getForm = (fieldsSchema) ->
  out = {}
  for key, {type, opts} of fieldsSchema
    out[key] = forms[capitalize(type) + 'Field'](opts)

  forms.Form.extend out
  #   id: forms.CharField(maxLength: 100, label: 'Code')

module.exports = (schema) ->
  React.createClass
    mixins: [ Router.Navigation ]
    displayName: schema.getKeyName() + 'CreateItem'
    schema: schema

    getInitialState: ->
      isLoading: no

    onSubmit: (e) ->
      e.preventDefault()

      form = @refs.form.getForm()
      if form.validate()
        @setState isLoading: yes
        request.post(@schema.getUrl(), data: serialize(form.cleanedData, @schema)).then (reply) =>
          @transitionTo @schema.getRouteName('Show'), id: reply.data?.id

    getForm: ->
      getForm @schema.get 'views.create.fields'

    getTitle: ->
      if displayName = @schema.get('views.create.displayName')
        displayName
      else if displayName = @schema.get('items.displayName')
        "New #{displayName}"
      else
        "New Item"

    getSubmitButtonTitle: ->
      @schema.get('views.create.submitButtonTitle') or "Create " + @getTitle()

    render: ->
      # console.log @getPath(), @getPathname(), @getParams()
      return <Spinner /> if @state.isLoading

      <div>
        <h2>{@getTitle()}</h2>
        <form onSubmit={@onSubmit}>
          <RenderForm form={@getForm()} ref="form"/>
          <button className="button" type="submit"> <Icon name="plus"/> {@getSubmitButtonTitle()}</button>
        </form>
      </div>
