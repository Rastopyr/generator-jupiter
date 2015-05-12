
path = require 'path'

require 'colors'
_ = require 'lodash'
Walk = require 'walk'

class Loader
  constructor: (options) ->
    if @ not instanceof Loader
      return new Loader options

    options = options || {}

    @.path = path.join pathes.app, options.path

    @.walkOptions =
      listeners:
        files: @.filesHandler.bind @
        errors: @.errorHandler   

    @.fixtures = []                                                                                                              

    this.init()

    return @

  ###
  # Initialization loader
  ###
  init: () ->
    this.load()

  ###
  # Load fixtures from file systems
  ###
  load: () ->
    Walk.walkSync this.path, this.walkOptions

  ###
  # Validate fixture file
  ###
  validate: (fixture) ->
    keys = ['model', 'name', 'data', 'idProp']
    
    _.every keys, (key) ->
      return if fixture[key] then true else false

  ###
  # Handler for fixture files
  ###
  filesHandler: (root, files, next) ->
    self = @
    fixtures = []

    _.each files, (fixture) ->
      fixtures.push require path.join root, fixture.name

    @.fixtures = @.fixtures.concat _.filter fixtures, @.validate

    next()

  ###
  # Error handling
  ###
  errorHandler: (err) ->
    console.log 'Error: ', err.message.red
    process.exit()


module.exports = Loader
