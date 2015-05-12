
path = require 'path'

_ = require 'lodash'
mime = require 'mime'

fs = getLibrary 'fs'

class Parser
  constructor: (pathFile, options) ->
    if @ not instanceof Parser
      return new Parser pathFile, options

    options = options || {}

    @.pathFile = pathFile
    @.options = _.extend @.options, options

    @.preloadParsers()

    if not options.ext
      @.mime = @.parseMime()
      @.ext = @.parseExt().toUpperCase()
    else
      @.ext = options.ext

    return @.types[@.ext] pathFile, options

  parseMime: () ->
    return mime.lookup @.pathFile

  parseExt: () ->
    return mime.extension @.mime

  preloadParsers: () ->
    self = @
    self.types = {}

    pathToMappers = path.join pathes.app, 'lib/parser'

    files = fs.readDirJsSync pathToMappers

    _.each files, (file, key, list) ->
      name = path.basename file, path.extname file
      parserKey = name.toUpperCase()

      self.types[parserKey] = require(path.join(pathToMappers, name))[parserKey]

    return @

module.exports = Parser
