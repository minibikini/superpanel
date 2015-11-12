{React, Spinner, request, F} = require '../toolbelt'
{Icon} = F
{Form} = require('formsy-react')
{Input} = require 'formsy-react-components'

module.exports = React.createClass
  displayName: 'Login'
  getInitialState: ->
    isLoading: no
    error: null

  onSubmit: (data) ->
    @setState
      isLoading: yes
      formFata: data
      error: null

    request.post('/api/auth/login', data)
    .catch (e) =>
      @setState
        isLoading: no
        error: e.message or e.error.message
    .then ({user}) =>
      @props.onLogin user

  render: ->
    return <Spinner /> if @state.isLoading

    if @state.error
      error = <div style={backgroundColor: 'red', padding: '20px', marginBottom: '20px'}>{@state.error}</div>

    [usernameLabel, usernameType] = if _superpanel_usernameField is 'email'
      ['Email', 'email']
    else
      ['Username', 'text']

    <div style={margin: 'auto', maxWidth: '300px', marginTop: '100px'}>
      <h2>Login</h2>
      {error}
      <Form onSubmit={@onSubmit}>
        <Input name={_superpanel_usernameField} type={usernameType} label={usernameLabel} value={@state.formFata?[_superpanel_usernameField]}/>
        <Input name="password" type="password" label="Password" />
        <button className="button" type="submit"><Icon name="sign-in"/> Sign In</button>
      </Form>
    </div>
