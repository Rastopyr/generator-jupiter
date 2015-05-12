
require 'colors'
_ = require 'lodash'
async = require 'async'

class Simple
  constructor: (fixture, database) ->
    if @ not instanceof Simple
      return new Simple fixture, database

    @.fixture = fixture
    @.database = database

    # init fixture
    @.init()

  ###
  # Initialization fixture
  ###
  init: () ->
    if _.isArray @.fixture.data
      return @.exportMany()

    return @.exportSingle()

  ###
  # Logging to console
  ###
  log: () ->
    args = Array.prototype.slice.call arguments

    predicat = ["#{@.fixture.name}-".bgRed].concat args

    console.log.apply console, predicat

  ###
  # Expot many method
  ###
  exportMany: () ->
    self = @

    async.waterfall [
      @.filterMany.bind @
      (filtered, next) ->
        existed = self.fixture.data.length - filtered.length

        if existed
          self.log 'Exists: '.green, (""+existed).green

        self.countToInsert = filtered.length

        if filtered.length
          self.log "To insert: ".green, (""+filtered.length).green

        self.insertMany filtered, next
      (inserted) ->
        self.countInserted = inserted.length
        self.countNotInsert = self.countInserted - inserted.length

        if inserted.length
          self.log "Inserted: ".green, (""+inserted.length).green
        if self.countNotInsert
          self.log "Not inserted: ".dim, (""+self.countNotInsert).dim
    ], (err) ->
      self.log 'err', err

  ###
  # Filter entities, which exists
  ###
  filterMany: (callback) ->
    self = @
    idProp = @.fixture.idProp

    async.filter @.fixture.data, self.filterSingle.bind(@), (filtered) ->
      callback null, filtered

  ###
  # Insert multiple parallel entities
  ###
  insertMany: (toInsert, callback) ->
    self = @

    async.filter toInsert, self.insertSingle.bind(@), (inserted) ->
      callback null, inserted

#=================================Single========================================
  ###
  # Export single entity
  ###
  exportSingle: () ->
    self = @

    async.waterfall [
      (next) ->
        self.filterSingle self.fixture.data, (exist) ->
          return next null, self.fixture.data if exist

          return next null, null
      (toInsert, next) ->
        if not toInsert
          self.log "Exist: 1".green
          process.exit()

        self.countToInsert = 1
        self.log "To insert: 1".green

        self.insertSingle toInsert, (isInserted) ->
          return next null, 1 if isInserted

          return next null, 0
      (count) ->
        self.countInserted = count
        self.countNotInsert = self.countToInsert - self.countNotInsert

        self.log "Inserted: ".green, (""+inserted.length).green
        self.log "Not inserted: ".dim, (""+self.countNotInsert).dim

    ], (err) ->
      self.log err

  ###
  # Filter single entity
  ###
  filterSingle: (item, callback) ->
    query = {}
    idProp = @.fixture.idProp

    query[idProp] = item[idProp]

    @.database.findOne query, (err, fixture) ->
      return callback false if err

      return callback false if fixture

      return callback true

  ###
  # Insert one entity
  ###
  insertSingle: (item, callback) ->
    @.database.model
      .build(item)
      .save().done callback
  

exports = {
  Simple
}

module.exports = exports
