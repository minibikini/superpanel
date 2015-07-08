config = require '../config/config'

r = require('rethinkdbdash')(config.rethinkdb)

module.exports = r