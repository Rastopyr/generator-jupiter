
###
# Expose dependencies
###

path = require 'path'

require 'colors'

_ = require 'lodash'
async = require 'async'
Promise = require 'bluebird'

Walker = require 'walk'
Sequelize = require 'sequelize'

fs = getLibrary 'fs'

Migrator = getLibrary 'migration/migrator'
MigrationMap = getLibrary 'migration/createmap'
Mapper = getApplication 'static/database/postgres/mapper'

error = getUtility 'error'

###
# Expose utility functions
###

loadMigrations = (subpath) ->
  migrations = {}
  pathToMagrations = path.join pathes.app, 'migration', subpath

  options =
    listeners:
      files: (root, fileArray, next) ->
        _.each fileArray, (file) ->
          pathToFile = path.join root, file.name

          name = path.basename file.name, path.extname file.name

          time = name.split('-')[1]

          migrations[time] =
            name: name
            migration: require pathToFile
            time: time
            path: pathToFile
            extname: file.name

          next()
      errors: (root, nodeStatsArray, next) ->
        console.log nodeStatsArray

  Walker.walkSync pathToMagrations, options

  return migrations


###
# Expose `Migration`
###

class Migration
  constructor: (options) ->
    # Create new instance, if contenxt not instanceof Migration
    if @ not instanceof Migration
      return new Migration options

    # Set options
    @.options = options
    @.version = options.version
    @.name = options.name
    @.action = options.action
    @.step = options.step
    @.latest = null
    @.current = null

    # Set mapper by ctx
    @.ctx = Mapper

    # Start initializations
    return new Promise (resolve, reject) =>
      @.init.apply @, arguments

  ###
  # Start migration loop
  ###
  init: (resolve, reject) ->
    map = @.migrationMap()  # init migration map

    map.on 'error', (err) ->
      reject err
      # error.throw err.message

    map.on 'initalizated', =>
      do @.walk

      @.startMigration resolve

  ###
  # Create migration map, if not exist
  ###
  migrationMap: () ->
    @.map = new MigrationMap @.ctx

  ###
  # Walk, collect and process migration files
  ###
  walk: () ->
    @.migrations = loadMigrations path.join @.name, @.version
    length = Object.keys(@.migrations).length
    console.log "(Migrations loaded: ".dim + "#{length})".dim

  ###
  # Start next migration
  ###
  startMigration: (callback) ->
    @map.getLatest (err, latest) =>
      return callback err if err

      if latest
        @.latest = @.getMigrationByMap latest
        @.current = @.getNextMigration latest
      else
        index = Object.keys(@.migrations).sort()[0]
        @.current = @.migrations[index]

      @.initAction callback

  ###
  # Start steps of
  ###
  initAction: (callback) ->
    options = limit: @.migrations.length

    return @[action]() if @.step is 1

    options.limit = @.migrations.length - @.step if @.step

    return @.startFromLatest(callback) if @.action is 'up'

    @.map.getLatest (err, latest) =>
      return callback err if err

      if not latest
        console.log "All migrations destroyed".green
        return do callback

      @.map.crud.find id: lte: latest.id, options, (err, results) =>
        return callback err if err

        @.downAll results, callback

  ###
  # Get migration by object from Migration Map
  ###
  getMigrationByMap: (migration) ->
    key = migration.name.split('-')[1]

    return @.migrations[key]

  ###
  # Get current item from migrations by latest
  ###
  getNextMigration: (latest) ->
    latestKey = latest.name.split('-')[1]
    keys = Object.keys(@.migrations).sort()
    nextKey = 0

    return @.migrations[keys[0]] if not latest

    _.each keys.sort(), (key, index) ->
      nextKey = keys[index+1] if key is latestKey

    return @.migrations[nextKey]

  startFromLatest: (callback) ->
    current = @.latest || @.current

    items = _.filter _.keys(@.migrations).sort(), (key, index) =>
      if current.time is @.latest?.time
        key > current.time
      else
        key >= current.time

    async.eachSeries items, (key, next) =>
      @.up @.migrations[key], next
    , (err) =>
      return callback err if err

      console.log "Insert #{items.length} migrations".green
      do callback

  downAll: (items, callback) ->
    async.filterSeries items, (toDown, next) =>
      migration = @.getMigrationByMap toDown

      @.down migration, (err) ->
        return next false if err

        next true
    , (results) =>
      query =
        id: _.pluck results, 'id'

      @.map.crud.destroy query, (err) =>
        console.log "Remove #{items.length} migrations".green
        callback err

  ###
  # Migration up
  ###
  up: (toInsert, callback) ->
    if 'function' is typeof toInsert
      cur = @.current
      callback = toInsert

    if toInsert and (callback or not callback)
      cur = toInsert

    if not toInsert and not callback
      cur = @.current

    cur.version = @.version

    migrator = Migrator Mapper

    cur.migration.up migrator, Sequelize, (err) =>
      return (callback err if callback) if err

      @.map.pushMigration cur, (err) ->
        return (callback err if callback) if err

        console.log "#{cur.name} migrated successfull".green

        do callback if callback

  ###
  # Migration down
  ###
  down: (toDown, callback) ->
    if 'function' is typeof toDown
      latest = @.latest
      callback = toInsert

    if toDown and (callback or not callback)
      latest = toDown

    if not toDown and not callback
      latest = @.latest

    migrator = Migrator Mapper

    latest.migration.down migrator, Sequelize, (err) =>
      return (callback err if callback) if err

      @.map.popMigration name: latest.name, (err) ->
        return (callback err if callback) if err

        console.log "#{latest.name} fallback successfull".green

        do callback if callback

module.exports = Migration
