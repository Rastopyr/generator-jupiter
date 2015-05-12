
path = require 'path'
{ EventEmitter } = require 'events'

_ = require 'lodash'
Promise = require 'bluebird'

Crud = getApplication 'static/database/postgres/crud'
UrlGenerator = getLibrary 'seo/generator/url'
MetaGenerator = getLibrary 'seo/generator/meta'

class SeoGenerator extends EventEmitter
  # @property [Number] bulkSize Size of `SELECT`, `UPDATE`, `INSERT` data
  bulkSize: 1000

  meta:
    relProperties: []
    properties: []

  count:
    exist: 0
    url: 0
    meta: 0
    saved: 0

  # Create intance of SeoGenerator by options
  #
  # @param [Object] options Options for instcne
  # @option options [Array] prefixes Array of prefixes. Prefix type is String
  # @option options [String] modelName Name of model for Crud
  # @option options [Array] relations List of relations for building seo
  # @option options [Array] properties
  # @option options.properties.item [Number] priority
  # @option options.properties.item [Number] property
  # @option options.relations.item [String] property 
  # @option options.relations.item [String] modelName
  # @option options.relations.item [String] modelProperty
  # @option options.relations.item [Number] priority
  # @return [SeoGenerator] Instance of SeoGenerator
  constructor: (options) ->
    if @ not instanceof SeoGenerator
      return new SeoGenerator options


    @.seoModel = Crud 'seo'
    @.crud = Crud options.modelName
    @.relations = options.relations
    @.properties = options.properties || []
    @.prefixes = options.prefixes || []
    @.tableName = @.crud.model.options.tableName

    # @.meta.relProperties = options.meta.relProperties
    # @.meta.properties = options.meta.properties

    @.bulkSize = options.bulkSize if options.bulkSize

  generate: () ->
    @.count()
      .bind(@)
      .then(@.setCount)
      .then(@.buildAllModels)

  # Get count of all objects in table
  # @return [Promise<Integer>] Count of all object in table
  count: () -> @.crud.model.count()

  # Set count model
  # @return [Number] Count of Object in table
  setCount: (count) -> @.modelCounts = count

  buildAllModels: () ->
    steps = [0...(Math.ceil @.modelCounts/@.bulkSize)]

    Promise.reduce [0...1], (step, curStep) =>
      @.getToSeoItems(curStep)
        .bind(@)
        .map(@.generateSeoObject)
        .map(@.generateUrl, 500)
        .map(@.generateMeta, 500)

        # .then(@.generateUrls.bind(@))
    , 0

  generateSeoObject: (item) ->
    seo:
      tableName: @.crud.options.tableName
      id: item.id
    instance: item

  # Generate meta object
  generateMeta: (payload) ->
    seoModelObejct = payload.seo
    item = payload.instance



  # Generate urls by list item
  generateUrl: (payload) ->
    # Promise.map(items, (item) =>
    seoModelObejct = payload.seo
    item = payload.instance

    ug = UrlGenerator(
      instance: item
      relations: @.relations
      properties: @.properties
      prefixes: @.prefixes
    )

    ug.generate()
      .then (url) ->
        seoModelObejct.url = url
        return payload 
    # , 500)

  # Get list of entites from `@.crud` for seonization
  # 
  # @return [Promise]
  getToSeoItems: (step) ->
    new Promise (resolve, reject) =>
      @.crud.find {},
        offset: step*@.bulkSize
        limit: @.bulkSize
      , (err, items) ->
        return reject err if err
        resolve items


module.exports = SeoGenerator
