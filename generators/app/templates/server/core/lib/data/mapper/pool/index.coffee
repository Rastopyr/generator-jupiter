
path = require 'path'
join = path.join

_ = require 'underscore'

fs = getLibrary 'core/fs'
string = getUtility 'core/string'
error = getUtility 'core/error'


class Pool
	constructor: (options) ->
		if 'string' is typeof options
			type = options

		options = options || {}

		if options.type
			type = options.type
			delete options.type

		@preload()

		if not type
			error.throw "Type not specified for pool", "TYPENSPCFIED"

		if not @types[type]
			error.throw "#{type} pool not exist in pool list", "POOLNEXST"

		return new @types[type] options
	preload: () ->
		self = @
		self.types = {}

		pathToMappers = join pathes.core, 'lib/data/mapper/pool', 'types'

		files = fs.readDirJsSync pathToMappers

		_.each files, (file, key, list) ->
			name = path.basename file, path.extname file
			poolKey = string.capitalize name

			self.types[poolKey] = require(join(pathToMappers, name))[poolKey]

		return @

exports = Pool

module.exports = exports
