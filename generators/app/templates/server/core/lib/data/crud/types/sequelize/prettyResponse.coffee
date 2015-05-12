
_ = require 'lodash'
debug = require('debug') 'data:sequelize:crud:query'

class PrettyResponse

  constructor: (model, options) ->
    @.model = model
    @.options = options

  # Iteration of pretty response
  #
  # @param  [Object]  data  Any data from sequelize response
  # @param  [Object]  newData  Object contain beauty payload
  # @param  [Object]  assoc  Sequelize association object
  # @param  [String]  name  Name of association
  prettyResponseByAssoc: (data, newData, assoc, name) ->
    return data if assoc.associationsType is 'BelongsToMany' and
        (data[assoc.as] or data[assoc.foreignKey])

    return newData if not data?[name]

    newData[assoc.as] = data[name].dataValues

    _.each _.keys(assoc.source.attributes), (prop, key) ->
      if data?[prop] and not newData[prop]
        newData[prop] = data[prop]
    , @

    return newData

  # Do reponse from query is pretty object.
  #
  # @param  response  [Object]  Any reponse from Sequelize query
  pretty: (response) ->
    _.chain(@.model.associations)
      .reduce(_.partial(@.prettyResponseByAssoc, response), {}, @)
      .value()

module.exports = PrettyResponse
