
_ = require 'lodash'
debug = require('debug') 'data:sequelize:crud:query'

class OptionsBuilder

  # @property [Boolean]
  # Auto include all associations in response.
  isIncludeAccocs: true

  # @property [Boolean]
  # Include all association if `isIncludeAccocs` true
  allAssocInclude: false

  constructor: (model, options) ->
    @.model = model
    @.options = options || {}

    @.isIncludeAccocs = @.options.isIncludeAccocs if @.options.isIncludeAccocs
    @.allAssocInclude = @.options.allAssocInclude if @.options.allAssocInclude

  assocInOptions: (options, assoc) ->

    return true if options.where[assoc.as]

    assocObject = _.find options.attributes, (item, k, list) =>
      'object' is typeof item

  # Prepare options by association
  #
  # @param  [Object]  options  Default options for Sequelize
  # @param  [Sequelize.Association] assoc  Default Sequelize association
  # @param  [String] name  Name of assocaiton
  buildAssoc: (options, assoc, name) ->
    where = {}

    return if not @.assocInOptions options, assoc

    localAttrs = _.find options.attributes, (item, k, list) =>
      if  'object' isnt typeof item or _.keys(item).indexOf(name) is -1
        return false

      options.attributes = list.slice(0, k).concat list.slice k+1, list.length

    if @.allAssocInclude
      attributes = _.keys assoc.target.attributes
    else if localAttrs?[name]?.length
      attributes = _.map localAttrs[name], (a)->
        if 'string' is typeof a
          a.replace ///^#{name}\.///, ''

        a
    else
      attributes = []

    if options.where?[name]
      where = options.where[name]
      delete options.where[name]
    else if options.where?[assoc.foreignKey]
      where = options.where[assoc.foreignKey]
      delete options.where[assoc.foreignKey]
    else if options.where?[assoc.as]
      where = options.where[assoc.as]
      delete options.where[assoc.as]

    opts =
      where: where
      attributes: attributes

    i = @.includeAccocs opts, assoc.target

    if assoc.associationType is 'BelongsToMany'
      i =
        association: assoc
        as: assoc.as
        attributes: _.filter attributes, (a) -> 'string' is typeof a
        through:
          attributes: []

      if where and _.keys(where).length
        i.where = where

      return i

    association: assoc
    where: where
    attributes: _.filter attributes, (a) -> 'string' == typeof a
    as: assoc.as
    model: assoc.target
    include: i.include

  # Prepeare options for sequelize
  #
  # @example
  #   where:
  #     id: 1
  #     # 'admin/adminstatus': id: 2
  #     # 'admin/admintype':
  #     #   id: 3
  #     #   'permissions': id: [1]
  #   attributes: [
  #     'admin/adminstatus': ['id', 'name']
  #   ,
  #     'admin/admintype': [ 'id'
  #     ,
  #       'permissions': [
  #         'id'
  #         'name'
  #       ]
  #     ]
  #   , 'id'
  #   ]
  #
  # @param  [Object]  options  Options like from @example
  # @param  [Sequelize.Model] model  Simple Sequelize.Model
  includeAccocs: (options, model) ->
    model = model || @.model
    assocs = model.associations

    debug 'parse model include of %s', model.name

    options.include = _.chain(assocs)
      .map(@.buildAssoc.bind(@, options))
      .filter((i) -> i)
      .value()

    if @.allAssocInclude
      options.attributes = _.keys @.model.attributes

    options.where = options.where || {}

    options

module.exports = OptionsBuilder
