
path = require 'path'

debug = require('debug') 'data:fixture:postgres:replicator'
_ = require 'lodash'

fs = getLibrary 'fs'
string = getUtility 'string'

Crud = getApplication 'static/database/postgres/crud'

class Replicator
  constructor: (fixture, database) ->
    if @ not instanceof Replicator
      return new Replicator fixture, database

    debug 'new replicator %s', fixture.name

    # copy arguments. fixture object
    @.fixture = fixture
    @.database = database

    # Create fixture by fixture name
    @.crud = Crud fixture.model

    # preload replicators type
    @.preload()

    # start factory
    @.init()

    return @

  ###
  # Initialization method
  ###
  init: () ->
    self = @

    relations = _.groupBy @.fixture.relations, (relation) ->
      string.capitalize relation.type

    if not Object.keys(relations).length
      self.types['Simple'] self.fixture, self.crud
      return

    _.each relations, (rels, name) ->
      cruds = _.map rels, (relation) ->
        Crud relation.model

      name = string.capitalize name

      self.types[name] self.fixture, self.crud, cruds, rels

  ###
  # Preload types of replicators
  ###
  preload: () ->
    self = @
    self.types = {}

    pathToMappers = path.join pathes.app, 'lib/fixture/postgres/replicators'

    files = fs.readDirJsSync pathToMappers

    _.each files, (file, key, list) ->
      name = path.basename file, path.extname file
      mapperKey = string.capitalize name

      self.types[mapperKey] = require(path.join(pathToMappers, name))[mapperKey]

module.exports = Replicator
