React = require 'react'

module.exports = React.createClass
  displayName: "Spinner"
  # mixins: [React.addons.PureRenderMixin]
  getStyles: ->
    if @props.width and @props.height
      # position: 'relative'
      width: @props.width + 'px'
      height: @props.height - 92 + 'px'

  render: ->
    <div className="spinner-container" style={@getStyles()}>
      <div className="spinner">
        <div className="double-bounce1"></div>
        <div className="double-bounce2"></div>
      </div>
    </div>
