
_ = require 'lodash'
Promise = require 'bluebird'

Crud = getApplication 'static/database/postgres/crud'

class SeoRelationUrlPrefixes

  seoModel: Crud 'seo'

  prefixes: []
  
  constructor: (instance, relations) ->
    if @ not instanceof SeoRelationUrlPrefixes
      return new SeoRelationUrlPrefixes instance, relations

    @.instance = instance
    @.relations = relations || []

  setRelations: () ->
    Promise.map(@.relations, @.setRelation.bind(@))

  setRelation: (relation) ->
    @.findOneForRelation.bind(@)(relation)
      .then(@.createPrefixes.bind(@, relation))

  createPrefixes: (relation, item) ->
    priority: relation.priority || 0
    value: item[relation.modelProperty]
    property: relation.property

  findOneForRelation: (relation) ->
    crud = Crud relation.modelName

    query = {}
    query[relation.queryProperty] = @.instance[relation.property]
    new Promise (resolve, reject) ->
      crud.findOne query,
          fields: [relation.property]
        , (err, item)->
          return reject err if err
          resolve item

module.exports = SeoRelationUrlPrefixes
