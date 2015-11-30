_ = require 'lodash'
{Form} = require('formsy-react')
{Select, Input} = require 'formsy-react-components'

opFields = [
  {value: 'startsWith', label: 'Starts With'}
  {value: 'match', label: 'RegExp'}
  {value: 'eq', label: '=='}
  {value: 'ne', label: '!='}
  {value: 'gt', label: '>'}
  {value: 'ge', label: '>='}
  {value: 'lt', label: '<'}
  {value: 'le', label: '<='}
]

module.exports = CollectionIndexFilterForm = ({filter, schema, onChange}) ->
  return <div /> unless (collectionFields = schema.getFields()).length

  handleChange = (filter) ->
    if _.isPlainObject(filter)
      filter.value = _.trim filter.value
      onChange filter

  <Form onChange={_.throttle handleChange, 1000}>
    <Select name="field" options={collectionFields} value={filter?.field or collectionFields[0].value} />
    <Select name="op" options={opFields} value={filter?.op or opFields[0].value} />
    <Input name="value" value={filter?.value or ''} />
  </Form>

CollectionIndexFilterForm.displayName = 'CollectionIndexFilterForm'