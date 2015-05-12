
_ = require 'lodash'

Router = getLibrary 'server/protos/router'
Crud = getApplication 'static/database/sequelize/crud'

methods = ['get', 'post', 'put', 'delete']

class REST extends Router
  constructor: (options) ->
    @.crud = Crud options.modelName

    @.get ':id', @.getOneMethod
    @.patch ':id', @.patchMethod
    @.put ':id', @.putMethod
    @.delete ':id', @.deleteMethod
    @.get @.getMethod
    @.post @.postMethod

  getMethod: (req, res, next) ->
    query = @.crud
      .find(req.query)

  getOneMethod: (req, res, next) ->
    options = req.query or {}

    options.where = _.extend (options.where or {}), id: req.params.id

    query = @.crud
      .findOne(options)

  postMethod: (req, res, next) ->
    query = @.crud
      .create(req.body)

  putMethod: (req, res, next) ->
    values = req.body
    options = req.query

    options.limit = 1

    query = @.crud
      .update(values, options)

  deleteMethod: (req, res, next) ->
    values = req.body
    options = req.query

    options.limit = 1

    query = @.crud
      .destroy(values, options)


module.exports = exports = REST
