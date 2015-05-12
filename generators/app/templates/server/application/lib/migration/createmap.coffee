
EventEmitter = require('events').EventEmitter

require 'colors'
Sequelize = require 'sequelize'

Crud = getApplication('static/database/postgres/crud') 'migrationMap'

error = getUtility 'error'

class CreateMap extends EventEmitter
  constructor: (ctx) ->
    if ctx not instanceof Sequelize
      error.throw "Ctx in `createMap` not instanceof Sequelize"

    @.ctx = ctx
    @.crud = Crud


    @.init()

    return @

  ###
  # Start create Map
  ###
  init: () ->
    @.crud.model.sync(@.crud.model.sequelize.options.sync)
      .catch(
        (err) =>
          @.logFail err
          @.emit 'error', err
      )
      .then =>
        do @.logSuccess
        @.emit 'initalizated'
  ###
  # Log into cli about success create Map
  ###
  logSuccess: () ->
    console.log "Migration map has been initalizated".green

    return true

  ###
  # Log into cli about failed creating Map
  ###
  logFail: (err) ->
    console.log err
    console.log "Migration map initalizated failed".red, err
    process.exit()

  ###
  # Get latest migration
  ###
  getLatest: (callback) ->
    options =
      limit: 1
      order: [['createdAt', 'DESC']]

    return @get {}, options, callback

  ###
  # Get migration by query
  ###
  get: (query, options, callback)->
    @.crud.findOne query, options, callback

  ###
  # Push migration into map in database
  ###
  pushMigration: (migration, callback) ->
    @.crud.create migration, callback

  ###
  # Pop migration from map in database
  ###
  popMigration: (query, callback) ->
    @.crud.destroy query,
      limit: 1
    , callback

module.exports = CreateMap
