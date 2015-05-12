
_ = require 'lodash'
Sequelize = require 'sequelize'
debug = require('debug') 'data:fixture:postgres:fixture'

Repliactor = getLibrary 'fixture/postgres/replicator'

class Fixture
  constructor: (options) ->
    if @ not instanceof Fixture
      return new Fixture options

    debug 'new fixture'

    @.fixtures = options.fixtures
    @.database = options.ctx

    @.init()

    return @

  ###
  # Initialization method
  ###
  init: () ->
    debug 'initialization'

    self = @

    debug 'all fixtures %d', @.fixtures.length

    _.each @.fixtures, (fixture) ->
      self._insertFixture fixture, self.database

  ###
  # Insert or update relation to database
  ###
  _insertFixture: (fixture, database) ->
    debug 'start replicator for %s', fixture.name
    Repliactor fixture, database.models[fixture.model]


module.exports = Fixture
