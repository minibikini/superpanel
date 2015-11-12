config = require '../config/config'

module.exports = require('rethinkdbdash')(config.rethinkdb)

