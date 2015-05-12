
require 'colors'
_ = require 'lodash'
async = require 'async'
debug = require('debug') 'data:fixture:postgres'

database = getApplication 'static/database/postgres/mapper'

Loader = getLibrary 'fixture/postgres/loader'
Fixture = getLibrary 'fixture/postgres/fixture'

class Postgres
  constructor: (options) ->
    if @ not instanceof Postgres
      return new Postgres options

    loader = new Loader
      path: options.loadPath || 'fixtures'

    debug 'all %d', loader.fixtures

    new Fixture
      fixtures: loader.fixtures
      ctx: database

exports = {
  Postgres
}

module.exports = exports
