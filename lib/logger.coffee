bunyan = require('bunyan')
bformat = require 'bunyan-format'
_ = require 'lodash'
appConfig = require '../config/config'

config =
 name: appConfig.name

dev =
  level: 'debug'
  stream: bformat outputMode: 'short', color: yes

config = switch process.env.NODE_ENV
  when 'production' then config
  else _.defaults dev, config

module.exports = bunyan.createLogger config
