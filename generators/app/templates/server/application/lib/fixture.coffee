
path = require 'path'
join = path.join

_ = require 'lodash'

fs = getLibrary 'core/fs'
string = getUtility 'core/string'
error = getUtility 'core/error'

class Fixture
  constructor: (name, options) ->
    @preload()

    if not @types[name]
      error.throw "Types #{name} not exist in mapper list", "MPPRNEXST"

    return new @types[name] options

  ###
  # Preload types of factory
  ###
  preload: () ->
    self = @
    self.types = {}

    pathToMappers = join pathes.app, 'lib/fixture'

    files = fs.readDirJsSync pathToMappers

    _.each files, (file, key, list) ->
      name = path.basename file, path.extname file
      mapperKey = string.capitalize name

      self.types[mapperKey] = require(join(pathToMappers, name))[mapperKey]

    return @


module.exports = Fixture
