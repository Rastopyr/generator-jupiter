
{ EventEmitter } = require 'events'
{ join, sep } = require 'path'

_ = require 'lodash'

fs = getLibrary 'fs'
Exporter = getLibrary 'exporter/exporter'

class Adapter extends EventEmitter
  constructor: (options) ->
    @.options = options || {}

    @.exporter = new Exporter @.options

    return @

  # Identifier of export
  stamp: null,

  # instance of exporter
  exporter: null

  # upload, parse and save file
  upload: (emitter, next) ->
    file = emitter.body.file
    options = _.extend emitter.body.options, trim: true

    @.exporter.uploadFile file, options

    next()

  preview: (emitter, next) ->
    options = _.extend emitter.body.options, trim: true

    @.exporter.parse _.extend options, limitRows: 5

    @.exporter.on 'end', =>
      emitter.locals.stamp = @.exporter.ID
      emitter.locals.records = @.exporter.records

      next()

  EmitAtSecond: () ->
    prevTime = (new Date).getTime()
    i = 0
    
    (fn, args = []) ->
      curTime = new Date().getTime()

      if (curTime - prevTime) > 1000
        fn.apply(@, args)
        prevTime = (new Date).getTime()
      
      return

  # start export
  startExport: (emitter, next) ->
    options = emitter.body.options

    @.exporter.exportToDatabase _.extend options, limitRows: Infinity

    sendFunc = do @.EmitAtSecond

    sendLocals = () ->
      emitter.locals = @.exporter.info

      do emitter.send

    @.exporter.on 'countUpdate', =>
      sendFunc sendLocals.bind @

    @.exporter.on 'forceCountUpdate', =>
      do sendLocals.bind @

  decodeBase64: (emitter, next) ->
    file = emitter.body.file

    file = @.exporter.decodeBase64ToBinary file

    emitter.body.file = file

    do next

module.exports = Adapter
