
_ = require 'lodash'
Sequelize = require 'sequelize'

View = getLibrary 'view'

successJSON = (data, key) ->
  if data[key] not instanceof Sequelize.Instance
    return View.successJSON(data)

  d = {}

  payload = data[key]

  model = payload.Model

  if _.isArray payload
    rootName = _.pluralize model.name
  else
    rootName = _.singularize model.name

  d[rootName] = payload

  if _.isArray payload
    _.each payload, (item, index, list) ->
      _.each model.associations, (assoc, name) ->
        subRootName = _.pluralize assoc.target.name
        d[subRootName] = d[subRootName] || [];

        if _.isArray item[assoc.as]
          d[subRootName] = d[subRootName].concat item[assoc.as]
        else
          d[subRootName].push item[assoc.as]

        if list[index][name]
          delete list[index].dataValues[assoc.as]
  else
    _.each model.associations, (assoc, key) ->
      name = assoc.target.name
      if _.isArray payload[name]
        subRootName = _.pluralize name
      else
        subRootName = name

      d[subRootName] = payload[assoc.as]
      delete d[rootName][assoc.as]

  (req, res, next) ->
    View.successJSON(d) req, res, next

exports = {
  successJSON
}

module.exports = exports
