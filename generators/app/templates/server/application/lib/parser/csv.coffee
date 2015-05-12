
{EventEmitter} = require 'events'
util = require 'util'

_ = require 'lodash'
csv = require 'csv'

fs = getLibrary 'fs'
error = getUtility 'error'

class CSV extends EventEmitter
  constructor: (filePath, options) ->
    if @ not instanceof CSV
      return new CSV filePath, options

    options = options || {}

    @.output = []

    @.options = _.extend options, @.options

    @.filePath = filePath

    @.init()

    return @

  init: () ->
    @.parser = csv.parse @.options

    @.bindParser()

    this.emit 'sinfo', 'New `csv` parser is initialized'

  bindParser: () ->
    self = @
    count = 0

    @.parser.on 'readable', () ->
      while record = self.parser.read()
        if self.options.nextTick
          if self.options.nextTick count
            self.emit 'record', record
            ++count
          else
            return

     @.parser.on 'end', () ->
      self.emit 'end'

      self.isEnded = true

  parseFile: () ->
    fs.readFile @.filePath, ( err, chunk ) =>
      @.parser.write chunk.toString()
      @.parser.end()

exports =
  CSV: CSV

module.exports = exports
