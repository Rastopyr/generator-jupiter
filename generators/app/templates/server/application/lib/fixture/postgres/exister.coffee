
error = getUtility 'error'

Sequelize = require 'sequelize'
async = require 'async'

class Exister
  constructor: (options) ->
    @.ctx = options.ctx

    @init options

    return @

  ###
  # Initialization method
  ###
  init: (options) ->
    # if options.ctx not instanceof Sequelize
    #   error.throw "Ctx for execution not instanceof Sequelize", "CTXNTINTSQLZ"

  ###
  # Check existing entity by unique property id
  ###
  isExist: (entity, idProp, cb) ->
    query = {}

    query[idProp] = entity[idProp]

    @.ctx.findOne query, (err, finded) ->
      error.throw err.message if err

      return cb() if finded isnt null

      cb new Error 'entity exist'

  ###
  # Check existing entity by unique property id. Return boolean in callback
  ###
  isExistBoolean: (entity, idProp, cb) ->
    @.isExist entity, idProp, (err) ->
      return cb false if err

      cb true

  ###
  # Check existing entity by unique property id. Return boolean in callback
  ###
  isNotExistBoolean: (entity, idProp, cb) ->
    @.isExist entity, idProp, (err) ->
      msg = err?.message

      return cb true if msg is 'entity exist'

      cb false

  ###
  # Filter array of entites by existing
  ###
  isExistByArray: (entites, idProp, cb) ->
    self = @

    async.filter entites, (entity, next) ->
      self.isExistBoolean entity, idProp, next
    , (entities) ->
      cb null, entities

  ###
  # Filter array of entites by not existing
  ###
  isNotExistByArray: (entites, idProp, cb) ->
    self = @

    async.filter entites, (entity, next) ->
      self.isNotExistBoolean entity, idProp, next
    , (entities) ->
      cb null, entities

  ###
  # Filter array of entites by existing
  ###
  isExistByArrayWithDiff: (entites, idProp, cb) ->
    self = @

    existed = []
    notExisted = []

    async.each entites, (entity, next) ->
      self.isExistBoolean entity, idProp, (exist)->
        existed.push entity if exist is true

        notExisted.push entity if exist is false

        next()
    , (err) ->
      cb null, existed, notExisted

  ###
  # Validate fixture object in commonjs style
  ###
  validate: (entity, callback) ->
    return callback false if not entity.data and not entity.ref

    return callback true if not entity.ref and entity.data

    callback true

exports = {
  Exister
}

module.exports = exports
