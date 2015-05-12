
util = require 'util'
{ join } = require 'path'

debug = require('debug') 'data:sequelize:mapper:pool'
debugassoc = require('debug') 'data:sequelize:mapper:pool:assoc'

_ = require 'lodash'
Walker = require 'walk'
Sequelize = require 'sequelize'

fs = getLibrary 'core/fs'
error = getUtility 'core/error'

class SequelizePool

  # @property [Boolean] Flag of is loaded models
  isLoaded: false

  # Contructor of sequelize Pool. Set `Mapper` object to ctx and initialize models
  #
  # @param
  constructor: (options) ->
    @.ctx = options.ctx || null

    if not @.ctx
      error.throw "Ctx for SequelizePool not exist"

    if @.ctx not instanceof Sequelize
      error.throw "Ctx for SequelizePool is not instance of mongoose"

    @.load.call @

    return @

  # Load models from model derectory
  #
  # @param modelPath [String] Path to model directory
  # @return this [SequelizePool] SequelizePool instance
  load: (modelPath) ->
    @.modelPath = modelPath or join pathes.app, 'model'

    @.options =
      listeners:
        directories: @._readDirectories.bind @
        files: @._readFiles.bind @
        errors: (root, nodeStatsArray, next) ->
          console.log nodeStatsArray

    @.initialLoading = true

    @._loadModels.call @

    debug 'end model loaded'

    @.initialLoading = false

    do @.associateModels

    @.isLoaded = true

    return @

  # Validate and set models from array
  #
  # @private
  # @param  model
  _setModel: (model) ->
    debug 'new model %s', model.name

    if not model.type
      return false

    if model.type isnt 'Postgres' or model.type isnt 'Sequelize'
      debug 'model %s is not valid', model.name
      return false

    @.set model

  # Validate and set models from array
  #
  # @private
  # @param  models
  _setModels: (models) ->
    for model in models
      continue if not @._setModel model

  # Private method for loading directories
  #
  # @private
  # @param  root [String] Root directory
  # @param  dirStatsArray [fs.Stats] Stat array of files in directory `root`
  # @cb     callback [Function]
  _readDirectories: (root, dirStatsArray, cb) ->
    _.each dirStatsArray, (stat, kstat, list) ->
      pathToDir = join root, stat.name

      debug 'read directory %s', pathToDir

      @._loadModels.call @, pathToDir

      @._setModels fs.loadDirJsSync pathToDir
    , @

  # Loading directories
  #
  # @private
  # @param  root [String] Root directory
  # @param  fileStats [[fs.Stat]] Stat object of file in directory `root`
  # @cb     callback [Function]
  _readFiles: (root, fileStats, cb) ->
    _.each fileStats, (stat) ->
      return if not fs.isJsFile stat.name

      @._setModel require join root, stat.name
    , @

  # Recursive loading models in direcoty
  #
  # @private
  # @param [dir] [String] Path to directory for loading Sequelize models
  _loadModels: (dir) ->
    Walker.walkSync dir or @.modelPath, @.options

  # Create associations for all models
  #
  # @return [[Sequelize.Model]] Array of all models in ctx
  associateModels: () ->
    _.each @.ctx.models, (model, key, list) ->
      if not proto = model.proto
        return

      if not assocs = proto.options.associations
        return

      @.associateModel model, assocs
    , @

  # Create association for model
  #
  # @param model  [Sequelize.Model] Model for set associations
  # @param assocs [Array] List of associations for models
  associateModel: (model, assocs) ->
    _.each assocs, (assoc, assocType, list) ->
      if assocs instanceof Array
        return if 'string' is typeof assoc

        assocType = assoc.assocType

      if 'object' is typeof assoc
        if not assoc.modelName
          error.throw "Not exist model name for associations", "NTEXSTMDLNMFRASSOC"

        assocModel = @.ctx.models[assoc.modelName]

        debugassoc 'model "%s" have assoc to "%s" with type %s', model.name, assocModel.name, assocType

        model[assocType] assocModel, assoc

        return

      if 'string' is typeof assoc
        assocModel = @.ctx.models[assoc]

        model[assocType] assocModel
        return
    , @
  get: (name) ->
    @.ctx['models'][name] || null

  # Set model into model scope
  set: (model) ->
    if not model.type or (model.type isnt "Postgres" and model.type isnt "Sequelize")
      error.throw "Setted model not for Sequelize", "STTDMDLNFORPSTGRS"

    if not schema = model.schema
      error.throw "In model #{model.name} not exist schema field", "SCHMNEXST"

    if not options = model.options
      error.throw "In model #{model.name} not exist option field", "OPTSNEXST"

    options.instanceMethods = model.methods
    options.classMethods = model.static

    if @ctx.models[model.name]
      @ctx.models[model.name] = null

    @ctx.define model.name, model.schema, model.options

    @.ctx.models[model.name].proto = model

    if @.initialLoading is false and model.options.associations
      toAssocModel = @.ctx.models[model.name]
      assocs = model.options.associations

      @.associateModel toAssocModel, assocs, @.ctx

    @.ctx.models[model.name]

module.exports = exports = Sequelize: SequelizePool
