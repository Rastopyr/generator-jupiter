
Sequelize = require 'sequelize'
_ = require 'lodash'
debug = require('debug') 'data:sequelize:crud:query'

Scopes = Config.get 'scopes'

OptionsBuilder = getLibrary 'core/data/crud/types/sequelize/optionsBuilder'
Prettyfier = getLibrary 'core/data/crud/types/sequelize/prettyResponse'

class SequelizeCrud

  # @property [Boolean]
  # If true, return simple object
  isPrettyReponse: false

  # Constructor for SequelizeCrud class
  #
  # @param  [Object] options  Options for crud
  # @option  options [Boolean]  isIncludeAccocs
  # @option  options [Boolean]  includeAssocDepth
  # @option  options [Boolean]  isPrettyReponse
  constructor: (options) ->
    @.options = options

    @.isPrettyReponse = options.isPrettyReponse if options.isPrettyReponse
    @.isIncludeAccocs = options.isIncludeAccocs if options.isIncludeAccocs

    @.model = options.pool.get options.modelName
    @.optionsBuilder = new OptionsBuilder @.model, options
    @.prettyfier = new Prettyfier @.model, options

  # Remove some attributes
  excludeAttributes: (excludeList) ->

  findAll: (options={}, queryOptions={}) ->
    # scope = Scopes[@.model.name]

    if @.isIncludeAccocs
      options = @.optionsBuilder.includeAccocs options

    if scope?.get
      options = _.merge options, scope.get

      if scope.get.exclude
        options = @.excludeAttributes scope.get.exclude, options

    p = @.model
      .findAll
      .call(@.model, options, queryOptions)

    return p if not @.isPrettyResponse

    p.map (resp) -> @.prettyfier.pretty

  findOne: (options = {}, queryOptions = {}) ->
    # scope = Scopes[@.model.name]

    if @.isIncludeAccocs
      options = @.optionsBuilder.includeAccocs (options || {})

    if scope?.get
      options = _.merge options, scope.get

      if scope.get.exclude
        options = @.excludeAttributes scope.get.exclude, options

    p = @.model
      .findOne
      .call(@.model, options, queryOptions)

    if not @.isPrettyReponse
      return p

    p.then (resp) => @.prettyfier.pretty resp

  findAndCount: (options) ->
    # scope = Scopes[@.model.name]

    if @.isIncludeAccocs
      options = @.optionsBuilder.includeAccocs options, @.model

    if scope?.get
      options = _.merge options, scope.get

      if scope.get.exclude
        options = @.excludeAttributes scope.get.exclude, options

    p = @.model
      .findAndCount
      .apply(@.model, arguments)

    if not @.isPrettyResponse
      return p

    p.then (response) =>
      return response if not response.count

      response.rows = @.prettyfier.pretty response.rows

  count: (options) ->
    # scope = Scopes[@.model.name]

    if @.isIncludeAccocs
      options = @.optionsBuilder.includeAccocs options, @.model

    if scope?.get
      options = _.merge options, scope.get

      if scope.get.exclude
        options = @.excludeAttributes scope.get.exclude, options

    @.model
      .count
      .apply(@.model, arguments)

  create: (values) ->
    @.model
      .create
      .apply(@.model, arguments)

  destroy: () ->
    @.model
      .destroy
      .apply(@.model, arguments)

  bulkCreate: () ->
    @.model
      .bulkCreate
      .apply(@.model, arguments)


module.exports = exports = Sequelize: SequelizeCrud
