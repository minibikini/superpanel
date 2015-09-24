React = require 'react'
{Link} = require('react-router')
cx = require 'classnames'
_ = require 'lodash'
t = React.PropTypes

classNameType = t.oneOfType [t.string, t.array, t.object,]

Icon = React.createClass
  displayName: 'Icon'
  propTypes:
    name: t.string.isRequired
    className: classNameType

  render: ->
    <i className={cx 'fa', "fa-#{@props.name}", @props.className}></i>

# Table = React.createClass
#   displayName: 'Table'
#   propTypes:
#     className: classNameType
#     columns: t.arrayOf(t.object).isRequired
#     data: t.arrayOf(t.object).isRequired
#     vertical: t.boolean
#     horizontal: t.boolean

#   getDefaultProps: ->
#     horizontal: not @props.vertical
#     vertical: no

#   renderTable: ->
#     if @props.horizontal

#     else

#   render: ->
#     <table className={@props.className}>
#       {@renderTable()}
#     </table>


module.exports = {Icon}