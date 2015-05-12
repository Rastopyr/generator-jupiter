
path = require 'path'
join = path.join

_ = require 'underscore'

fs = getLibrary 'core/fs'
string = getUtility 'core/string'

class Server
	constructor: (options) ->
		options = options || {}

		if @ not instanceof Server
			return new Server options

		if 'string' is typeof options
			type = options
			options = {}
		else
			type = options.type || 'Single'

		@preload()

		return new @types[type] options
	preload: () ->
		self = @
		self.types = {}
		pathToTypes = join pathes.core, 'lib/server', 'types'

		files = fs.readDirJsSync pathToTypes

		_.each files, (file, key, list) ->
			name = path.basename file, path.extname file
			typeKey = string.capitalize name

			self.types[typeKey] = require join pathToTypes, name

		return @

module.exports = Server
