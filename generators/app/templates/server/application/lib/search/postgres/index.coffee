
_ = require 'lodash'

Crud = getApplication 'static/database/postgres/crud'
CrudOptions = getLibrary 'data/crud/types/postgres/options'
CrudQuery = getLibrary 'data/crud/types/postgres/query'

Rest = getLibrary('server/rest')
RestPostgres = getLibrary('server/rest/adapters/postgres').Postgres

RestResponse = Rest.RestResponse

buildDataRelations = RestPostgres.buildDataRelations

getRootName = (isArray, model) ->
  if isArray
    return _.pluralize model.name
  
  return model.name

prepareResponse = (data, meta) ->
  isArray = _.isArray data
  rootName = getRootName isArray, @.model

  d = {}
  d[rootName] = data
  if meta
    d.meta = meta

  buildDataRelations data, @.model, d

class Search
  # fields that searchs
  fields: []

  # model name
  modelName: '',

  # curd property
  crud: null,

  # model property
  model: null,

  ###
  # Constructor methd
  # @param {String} name Name of search model
  # @param {Object} options Options of search
  # @return {Search} new Instance of search
  ### 
  constructor: (name, options)->
    # allow create new instance without `new` operator
    if @ not instanceof Search
      return new Search name, options

    @.crud = Crud name

    @.model = @.crud.model

    @.fields = options.fields

    return @

  ###
  # Middleware for connect
  # @return {Function} Connect middleware function
  ###
  middleware: () ->
    self = @
    prepRes = prepareResponse.bind @

    (req, res, next) =>
      term = decodeURI(req.query.search).trim() || ''
      query = req.query.selector || {}
      options = new CrudOptions req.query, @.model

      response = new RestResponse res

      return response.success prepRes [] unless term

      @.do term, query, options, (err, models) ->
        if err
          return response.error err

        response.success prepRes models

  ###
  # Do search query
  # @param {String} searchTerm  String of search query
  # @param {Function} callback Callback that returns results
  # @return {[type]} [description]
  ###
  do: (searchTerm, query, options, callback) ->
    if 'function' is typeof options
      callback = options
      options = {}

    if 'function' is typeof query
      callback = query
      query = {}
      options = {}


    generator = @.model.sequelize.queryInterface.QueryGenerator
    tableName = @.model.tableName
    tableAs = generator.quoteTable(@.model.name)
    term = searchTerm.replace ///\s///g, ' & '

    toTsvectOrState = ""
   
    _.each @.fields, (field, k, list) ->
      if k is list.length-1
        return toTsvectOrState += "#{tableAs}.#{generator.quoteIdentifier(field)}"
      
      return toTsvectOrState += "#{tableAs}.#{generator.quoteIdentifier(field)} || "

    where = "to_tsvector('english', #{toTsvectOrState}) @@ to_tsquery('english', '#{term}:*')"
    orderBy = "ORDER BY ts_rank_cd(
                to_tsvector('english', #{toTsvectOrState}),
                plainto_tsquery('english', '#{term}')
              )"

    selectQuery = @.selectQuery(query, options)

    if selectQuery.match("OFFSET")
      if selectQuery.match("LIMIT")
        selectQuery = selectQuery.replace('LIMIT', " #{orderBy} LIMIT")
      selectQuery = selectQuery.replace('OFFSET', " #{orderBy} OFFSET")
    else if selectQuery.match("LIMIT")
      selectQuery = selectQuery.replace('LIMIT', " #{orderBy} LIMIT")
    else if selectQuery.match(///where///i)
      selectQuery = selectQuery.replace('WHERE', " #{orderBy} WHERE")
    else
      selectQuery = selectQuery.substr(0, selectQuery.length-1);
      selectQuery = "#{selectQuery} #{orderBy};"

    if selectQuery.match(///where///i)
      selectQuery = selectQuery.replace('WHERE', "WHERE #{where} AND")
    else if selectQuery.match("ORDER BY")
      selectQuery = selectQuery.replace("ORDER BY", "WHERE #{where} ORDER BY")
    else if selectQuery.match(///limit///i)
      selectQuery = selectQuery.replace(///limit///i, "WHERE #{where} LIMIT")
    else
      selectQuery = selectQuery.substr(0, selectQuery.length-1);
      selectQuery = "#{selectQuery} WHERE #{where};"

    @.model.sequelize.query(selectQuery).then (resp) =>
      results = resp[0]
      metadata = resp[1]

      callback null, _.map _.values(results), (item, key, list) =>
        i = @.prepareItemForBuild item, @.queryOptions.include

        model = @.model.build i,
          isNewRecord: false
          isDirty: false
          includeValidated: false
          include: @.queryOptions.include

        return model

  ###
  # Create `SELECT` string by `QueryGenerator` with postgres dialect
  # @param {Object} query Where object
  # @param {Object} options   Other options for string generator
  # @return {String} Select query string
  ###
  selectQuery: (query, options) ->
    selector = query.selector || query

    generator = @.model.sequelize.queryInterface.QueryGenerator

    buildedOpts = new CrudOptions options, @.model

    @.queryOptions = _.extend
      where: selector
    , buildedOpts.toExtend()

    generator.selectQuery @.model.tableName, @.queryOptions, @.model

  ###
  # Create object for included build
  # @param {Object} plainObject  Results of raw query
  # @param {Array} includes  Map of include options
  # @return {Object} Object for build model
  ###
  prepareItemForBuild: (plainObject, includes) ->
    newObject = {}

    removeKeyPrefix = (prefix, obj) ->
      newObj = _.clone obj

      _.each _.keys(newObj), (key) ->
        if key.match prefix
          replacedKey = key.replace prefix, ''
          newObj[replacedKey] = obj[key]
          delete obj[key]

      return newObj

    setNotInclude = (dest, src, inclds) ->
      keysForExtend = _.filter _.keys(src), (item) ->
        return _.some includes, (include) ->
          return not item.match ///^#{include.as}\.///

      _.each keysForExtend, (key) ->
        dest[key] = src[key]

    setInclude = (dest, src, inclds) ->
      _.each inclds, (include) ->
        if not dest[include.as]
          dest[include.as] = {}

        tableAs = include.as
        target = include.model
        attributes = _.keys target.attributes

        _.each attributes, (attr) ->
          dest[tableAs][attr] = src["#{tableAs}.#{attr}"]

        if include.include?.length
          newSrc = removeKeyPrefix ///#{tableAs}\.///, src

          setInclude dest[tableAs], newSrc, include.include

    return plainObject if not includes.length

    setNotInclude newObject, plainObject, includes
    setInclude newObject, plainObject, includes

    return newObject


module.exports = Search
