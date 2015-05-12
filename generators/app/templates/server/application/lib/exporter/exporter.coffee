
{ EventEmitter } = require 'events'
{ join, sep } = require 'path'

_ = require 'lodash'
R = require 'ramda'
debug = require 'debug'
async = require 'async'
Promise = require 'bluebird'

fs = getLibrary 'fs'
Parser = getLibrary 'parser'

Crud = getApplication 'static/database/postgres/crud'

class Exporter extends EventEmitter
  ###
  # Array of relations for extending models
  # example:
  #   prop: "Name"
  #   idProp: "name"
  #   modelName: "geo/city"
  #   extendProp: "id"
  ###
  relations: []

  ###
  # Model name of export files
  ###
  modelName: ''

  ###
  # Info about count of parsed/saved/errored documents
  ###
  info:
    parsed: 0
    saved: 0
    errored: 0

  ###
  # Array of parsed records
  ###
  records: []

  ###
  # Count of parsed rows
  ###
  parseRows: 5

  ###
  # Default format for export
  ###
  format: 'csv'

  ###
  #
  ###
  pathPrefixes: [
    pathes.base
    'files'
    'export'
  ]

  ###
  # Path of files
  # @c = config path
  # @p = parsed file path
  ###
  paths:
    c: ''
    p: ''

  hooks:
    pre: []
    post: []

  ###
  # Constructor
  # Set options to instance.
  ###
  constructor: (options = {}) ->
    @.options = options
    @.paths = {}

    @.exportName = @.options.exportName || ""
    @.relations = @.options.relations || []
    @.debug = debug "lib:exporter:#{@.exportName}"

    @.hooks.pre = options.hooks?.pre || []
    @.hooks.post = options.hooks?.post || []

    return

  ###
  # Check of nedeed parse next lines
  ###
  isParseNextLine: (limit) ->
    (count)->
      count < limit

  ###
  # Create timestamp for ID
  ###
  timestamp: ->
    @.ID = (new Date()).getTime()

  ###
  # Create filename by stamp and format
  ###
  createFileName: ->
    @.fileName = "export-#{@.exportName}-#{@.ID}.#{@.format}"

  ###
  # Create file paths
  ###
  createPaths: ->
    globalPath = R.apply join, R.concat @.pathPrefixes, [
      _.pluralize(@.exportName)
      @.ID.toString()
    ]

    @.paths.p = join globalPath, @fileName
    @.paths.c = join globalPath, 'config.json'

  ###
  # Create config-file
  ###
  createConfig:  ->
    fs.outputJsonSync @.paths.c, @.options

  ###
  # Update config and extend them
  ###
  updateConfig: (config) ->
    @.options = c = _.extend fs.readJsonSync(@.paths.c), config

    @.createConfig()

  ###
  # Decode base64 to binary encoding
  ###
  decodeBase64ToBinary: (data) ->
    # Remove headers from binary for decoding
    data = data.replace ///^data:.[\/a-z0-9]{1,};base64,///, ""

    # Convert to binary
    new Buffer data, 'base64'

  ###
  # Save file to server
  ###
  saveFile: (file) ->
    R.forEach(R.partialRight(R.bind, @)(R.call), [
      @.timestamp
      @.createFileName,
      @.createPaths
      @.createConfig
    ])

    fs.outputFileSync @.paths.p, file.toString()

  ###
  # Erease staticstic
  ###
  dropStat: ->
    @.info =
      parsed: 0
      errored: 0
      saved: 0

  ###
  # Save file from binary and save options
  ###
  uploadFile: (file, options) ->
    @.options = _.extend @.options, options

    @.saveFile file

  ###
  # Parse file with options
  ###
  parse: (options) ->
    @.records = []

    @.dropStat()

    if options.columns is false
      delete options.columns

    popts = _.extend @.options,
      columns: true
      nextTick: @.isParseNextLine options.limitRows

    parser = Parser @.paths.p, popts

    endParsing = () =>
      @.records = _.map @.records, (r) ->
        if options.include.row.length
          return _.pick r, options.include.row

        return r

      @.compareFields()

      @.setRelations =>
        @.emit 'end'

    parser.on 'record', (record) =>
      @.records.push record

    parser.on 'end', =>
      resultPreHook = _.flow.apply(_, @.hooks.pre) @.records

      if resultPreHook instanceof Promise
        return resultPreHook.then (item) ->
          do endParsing

      do endParsing

    parser.parseFile()

    return this

  ###
  # Set all relation in promise style
  ###
  setRelations: (endCallback) ->
    Promise.map(@.relations, @.setRelation.bind(@))
      .bind(@)
      .done endCallback

  ###
  # Set one relation to all record
  ###
  setRelation: (relation) ->
    values = _.pluck @.records, relation.prop
    crud = Crud relation.modelName
    query = {}
    options =
      attributes: [relation.idProp, relation.extendProp]
    query[relation.idProp] = values

    findPromise = new Promise (resolve, reject) ->
      crud.find query, options, (err, results) =>
        return reject err if err

        return resolve results

    findPromise.then (results) =>

      # isValid = (record) ->
      #   crud.model.build(record).validate()

      # Promise.filter(@.records, isValid)
      #   .then (filtered) =>
      #     @.records = filtered

      _.each results, (item) ->
        _.each @.records, (record, k, list) ->
          return if record[relation.prop] isnt item[relation.idProp]

          list[k][relation.prop] = item[relation.extendProp]
      , @

  ###
  # Compare fields of records
  ###
  compareFields: ->
    extendProps = @.options.extendFields

    _.each @.records, (record, k, list) =>
      keys = Object.keys record

      list[k] = _.extend record, extendProps

  ###
  # Create data of models
  ###
  createModelsData: () ->
    _.each @.records, (record, k, list) =>
      list[k] = @.createModelData.bind(@) record

  ###
  # Create model data
  ###
  createModelData: (record) ->
    nObj = {}
    config = @.options
    keys = Object.keys record
    extendProps = config.extendedProps

    _.each keys, (key) ->
      nkey = config.comparedField[key].value

      return if not nkey

      nObj[nkey] = record[key]

    if not Object.keys(config.extendFields).length
      return nObj

    i = _.extend nObj, config.extendFields

    return i

  ###
  # Export to database
  ###
  exportToDatabase: (config) ->
    self = @
    @.records = []

    @.updateConfig _.extend config,
      columns: true
      nextTick: @.isParseNextLine config.limitRows

    parser = Parser @.paths.p, config

    parser.on 'error', (err) =>
      @.info.errored++
      @.emit 'countUpdate'

    parser.on 'record', (record) =>
      @.info.parsed++
      @.emit 'countUpdate'

      @.records.push record

    endExport = =>
      @.records = _.map @.records, (r) ->
        if config.include.row.length
          return _.pick r, config.include.row

        return r

      @.setRelations =>

        @.createModelsData()
        @.compareFields()

        @.saveRecords()
          .then (instances) =>
            posthandlers = _.flow.apply _, @.hooks.post

            posthandlers instances

            @.emit 'forceCountUpdate'

    parser.on 'end', =>
      @.emit 'forceCountUpdate'

      resultOfItem = _.flow.apply(_, @.hooks.pre) @.records

      if resultOfItem instanceof Promise
        return resultOfItem.then (item) ->
          do endExport

      do endExport

    parser.parseFile()

    return this

  ###
  # Save records from `records` property
  ###
  saveRecords: () ->
    toBulked = []

    if @.records.length > 10000
      countOfArrays = Math.floor @.records.length/(@.records.length/10000)
      toBulked = _.chunk @.records, countOfArrays
    else
      toBulked.push @.records

    Promise.map(toBulked, @.insertBulk.bind(@))
      .then (chunks) =>
        @.emit 'forceCountUpdate'

        instances = _.flatten chunks

        return instances
        # cb()

  ###
  # Insert array of item to crud model
  ###
  insertBulk: (toBulked) ->
    debug 'start insert bulk chunk'
    crud = Crud @.options.modelName

    model = crud.model

    addOne = =>
      @.info.saved++
      @.emit 'countUpdate'

    errorOne = (err) =>
      # console.log err
      @.info.errored++
      @.emit 'countUpdate'

    fulfillBulked = (instances) =>
      @.info.saved+=toBulked.length
      @.emit 'forceCountUpdate'

      return instances

    rejectBulked = (err) =>
      # console.log err
      @.debug "error: %s", err.message
      @.emit 'forceCountUpdate'

      Promise.each toBulked, (record)->
        model.build(record)
          .save()
          .then(addOne, errorOne)

    model.bulkCreate(toBulked, returning: true)
      .then(fulfillBulked)
      .catch(rejectBulked)
      .then (instances) =>
        @.emit 'forceCountUpdate'
        return instances



module.exports = Exporter
