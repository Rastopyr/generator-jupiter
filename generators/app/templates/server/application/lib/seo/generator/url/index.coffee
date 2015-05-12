
path = require 'path'

_ = require 'lodash'

Prefixes = getLibrary 'seo/generator/url/prefixes'
RelationPrefixes = getLibrary 'seo/generator/url/relationPrefixes'

class UrlGenerator
  constructor: (options) ->
    if @ not instanceof UrlGenerator
      return new UrlGenerator options

    @.instance = options.instance
    @.relations = options.relations
    @.properties = options.properties
    @.prefixes = options.prefixes

  # Create full path of url for item by
  # `relations`, `properties` and `prefixes` in Promise
  # 
  # @example How to generate url from insatnce
  #   UrlGenerator(options)
  #     .generate().then console.log # log url path
  # 
  # @return [Promise]
  generate: () ->
    @.createPrefixes()
      .then(@.createUrl.bind(@))

  # Create full url path by prefix list
  # @param [Array<Object>] prefixes List of prefixes
  # @return [String]
  createUrl: (prefixes) ->
    prefixes = _.sortBy prefixes, 'priority'

    _.reduce prefixes, (p, pref) =>
      pref.value = @.createUrlLabel pref.value

      path.join p, pref.value
    , path.join.apply path, ['/'].concat @.prefixes

  # Create list of prefix for url path
  # 
  # @example Prefix Object
  #   ```coffeescript
  #     priority: 1     # Number of sorting for crate url path
  #     value: 'value'  # Some String or Number for insert to path   
  #   ```
  # @return [Array<Object>] Array of prefixes
  createPrefixes: () ->
    rps = []
    ps = []

    RelationPrefixes(@.instance, @.relations)
      .setRelations()
      .then((prefixes) -> rps = prefixes)
      .then(Prefixes.bind(null, @.instance, @.properties))
      .then((prefixes) -> ps = prefixes)
      .then -> rps.concat ps

  createUrlLabel: (label) ->
    label = label
      .replace(///[^A-Za-z\s\-]///g, '')
      .replace(///\s///g, '-')

    label.toLowerCase()

module.exports = UrlGenerator
