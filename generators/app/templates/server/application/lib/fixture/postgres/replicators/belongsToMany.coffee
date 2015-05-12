
require 'colors'
_ = require 'lodash'
async = require 'async'

Exister = getLibrary('fixture/postgres/exister').Exister

string = getUtility 'string'

class BelongsToMany
  constructor: (fixture, database, reldbs, relations) ->
    if @ not instanceof BelongsToMany
      return new BelongsToMany fixture, database, reldbs, relations

    @.fixture = fixture
    @.database = database
    @.reldbs = reldbs

    @.relations = relations

    @.predicat = "#{@.fixture.name}-".bgBlue.red

    @.exister = new Exister
      ctx: @.database

    # init fixture
    @.init()

  ###
  # initialization method
  ###
  init: () ->
    @.export()


  ###
  # Logging to console
  ###
  log: () ->
    args = Array.prototype.slice.call arguments

    console.log.apply console, [@.predicat].concat args

  ###
  # Log about count saved
  ###
  logResult: (results)->
    @.log "saved: #{results.length}"

  ###
  # Export method
  ###
  export: () ->
    self = @

    data = @.fixture.data
    idProp = @.fixture.idProp

    async.waterfall [
      @.getToInsert.bind @
      @.createInstances.bind @
      @.findByInstances.bind @
      @.createRelations.bind @
      @.logResult.bind @
    ], (err) ->
      console.log err
      self.log 'err'.red, err.message if err

  ###
  # Filter entities from fixture for insert
  ###
  getToInsert: (callback) ->
    data = @.fixture.data
    idProp = @.fixture.idProp

    @.exister.isNotExistByArray data, idProp, callback

  ###
  # Find items by instances
  ###
  findByInstances: (instances, callback) ->
    query = 
      or:
        id: []

    _.each _.pluck(instances, 'id'), (id) ->
      query.or.id.push id

    @.database.find query, callback

  ###
  # Build instances and save it
  ###
  createInstances: (items, callback) ->
    async.map items, @.insertSingle.bind(@) , callback

  ###
  # Build relations at array
  ###
  createRelations: (instances, callback) ->
    @.log "To insert: #{instances.length}".blue

    async.map instances, @.setAllRealtions.bind(@), callback

  ###
  # Create belongsToMany relation
  ###
  setAllRealtions: (instance, callback) ->
    self = @
    # async.each @.relations, @.setRelations.bind(@), callback
    async.each @.relations, (rel, next) ->
      options =
        fixture: self.getFixture instance
        accessors: self.getAccessors instance.options.include, rel
        reldb: self.getReldb rel
        relation: rel
        instance: instance
     
      self.setRelations options, next
    , callback

  ###
  # Get associations, which declared in constructor argument
  ###
  getAccessors: (includes, rel) ->
    query =
      associationType: string.capitalize rel.type
      as: (rel.as || rel.foreignKey)

    accessors = null
    

    _.each includes, (include) ->
      isContain = _.every query, (item, key) ->
        include.association[key] is item

      if isContain
        accessors = include.association.accessors

    return if not accessors then false else accessors

  ###
  # Get item from fixtures by instance
  ###
  getFixture: (i) ->
    query = {}
    idProp = @.fixture.idProp

    query[idProp] = i[idProp]

    _.find @.fixture.data, query

  ###
  # Return crud instance by relation from reldbs
  ###
  getReldb: (rel) ->
    _.find @.reldbs, (db) ->
      db.model.name is rel.model

  ###
  # Load relations by fixture
  ###
  setRelations: (options, callback) ->
    self = @

    crud = options.reldb
    relation = options.relation
    fixture = options.fixture
    relProp = relation.as
    idsProps = fixture[relProp]
    idProp = relation.foreignProp
    accessors = options.accessors
    instance = options.instance

    added = 0
    existedrels = 0

    # Add relations for each dependency item
    async.each idsProps, (prop, next) ->
      query = {}
      query[idProp] = prop

      # find relation
      crud.findOne query, (err, item) ->
        # set to item
        instance[accessors.add](item)
          .then(
            (rel)->
              # increment counts for logging
              existedrels++ if not rel
              added++ if rel
              next()
          )
          .catch (err) ->
            self.log 'err', err.message
    , (err) ->
      if added
        self.log 'relations added: '.green, added

      if existedrels
        self.log 'relations exists: '.green, existedrels

      callback null, options.instance

  ###
  # Create and save one item
  ###
  insertSingle: (entity, callback) ->
    self = @

    @.database.model
      .build(entity)
      .save().done callback

exports = {
  BelongsToMany
}

module.exports = exports
