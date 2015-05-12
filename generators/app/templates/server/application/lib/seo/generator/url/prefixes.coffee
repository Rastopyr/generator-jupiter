
_ = require 'lodash'

class SeoUrlPrefixes
  constructor: (instance, properties = []) ->
    if @ not instanceof SeoUrlPrefixes
      return new SeoUrlPrefixes instance, properties

    return _.map properties, (v) ->
      priority: v.priority || 0
      value: instance[v.property]
      property: v.property

module.exports = SeoUrlPrefixes
