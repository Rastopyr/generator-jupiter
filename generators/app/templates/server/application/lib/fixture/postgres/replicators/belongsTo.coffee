
require 'colors'
_ = require 'lodash'
async = require 'async'

Exister = getLibrary('fixture/postgres/exister').Exister

string = getUtility 'string'

class BelongsTo
  constructor: (fixture, database, reldbs, relations) ->
    if @ not instanceof BelongsTo
      return new BelongsTo fixture, database, reldbs, relations

    @.fixture = fixture
    @.database = database
    @.reldbs = reldbs

    @.relations = relations

    @.predicat = "#{@.fixture.name} -".bgGreen

    @.exister = new Exister
      ctx: @.database

    # init fixture
    @init()

  ###
  # Initialization method
  ###
  init: () ->
    # just start export
    @.export()

  ###
  # Logging to console
  ###
  log: () ->
    args = Array.prototype.slice.call arguments

    console.log.apply console, [@.predicat].concat args

  ###
  # Expot method
  ###
  export: () ->
    self = @

    data = @.fixture.data
    idProp = @.fixture.idProp

    async.waterfall [
      @.getToInsert.bind @
      @.buildRelations.bind @
      @.saveAll.bind @
    ], (err) ->
      self.log 'err'.red, err.message

  ###
  # Filter entities from fixture for insert
  ###
  getToInsert: (next) ->
    data = @.fixture.data
    idProp = @.fixture.idProp

    @.exister.isNotExistByArray data, idProp, next

  ###
  # Build relations at array
  ###
  buildRelations: (toinsert, callback) ->
    self = @

    @.log "To insert: #{toinsert.length}".blue

    async.map toinsert, self.setAllRealtions.bind(@), callback

  ###
  # Setting relations loop
  ###
  setAllRealtions: (item, cb) ->
    self = @

    async.each @.reldbs, (reldb, next) ->
      modelName = reldb.options.modelName

      relation = _.find self.relations, model: modelName

      self.setRelations item, relation, reldb, next
    , (err) ->
      return cb err if err

      cb null, item

  ###
  # Set relations by relation options
  ###
  setRelations: (fixture, relation, reldb, next) ->
    model = @.database.model
    relProp = relation.as
    idProp = relation.foreignProp
    gProp = relation.gettedProp

    # instance = model.build fixture

    query = {}
    query[idProp] = fixture[relProp]

    added = 0
    notexisted = 0

    # find relation
    reldb.findOne query, (err, item) ->
      return next new Error 'relation not exist' if not item
      
      # set item to fixture
      fixture[relProp] = item[gProp]

      next null, fixture

  ###
  # Build instance of model and save instances
  ###
  saveAll: (items) ->
    self = @

    notsaved = 0

    async.each items, (item, next) ->
      instance = self.database.model.build item

      instance.save().done (err) ->
        self.log 'err:'.red, err.message if err
        notsaved++ if err

        next()
    , (err) ->
      if notsaved
        self.log "not saved: #{notsaved}".red

      if saved = self.fixture.data.length - notsaved
        self.log "saved: #{saved}".green

exports = {
  BelongsTo
}

module.exports = exports
