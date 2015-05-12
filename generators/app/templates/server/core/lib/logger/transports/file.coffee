
path = require 'path'
join = path.join

winston = require 'winston'
dateformat = require 'dateformat'

fs = getLibrary 'core/fs'

wFile = winston.transports.File

logDirectory = join pathes.server, 'logs'

class DateFile extends wFile
	constructor: (options) ->
		options = options || {}

		options.dateFormat = options.dateFormat || 'DD-MM-YYYY'
		options.logName = options.logName || 'default'

		@dateFormat = options.dateFormat
		filename = dateformat new Date(), @dateFormat

		@date = filename

		options.filename = filename+'.log'
		options.dirname = join logDirectory, options.logName
		options.json = true

		fs.ensureDirSync options.dirname

		super

		return @
	log: () ->
		today = dateformat new Date(), @dateFormat

		if today is @date
			return super

		@date = filename
		@filename = @date+'.log'
		@close()
		@open()
		super

class File
	constructor: (options) ->
		options = options || {}

		if options.logName
			return new DateFile options

		return new wFile options

exports.File = File

module.exports = exports
