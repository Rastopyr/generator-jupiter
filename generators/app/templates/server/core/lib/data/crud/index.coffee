
path = require 'path'
join = path.join

_ = require 'underscore'

fs = getLibrary 'core/fs'
string = getUtility 'core/string'
error = getUtility 'core/error'

class Crud
	constructor: (type, options) ->
		type = type || ''

		@preload()

		if not type
			error.throw "Type not specified for CRUD", "TYPENSPCFIED"

		if not @types[type]
			error.throw "#{type} crud not exist in crud list", "CRDNEXST"

		if not options
			return @types[type]

		return new @types[type] options
	preload: () ->
		self = @
		self.types = {}

		pathToMappers = join pathes.core, 'lib/data/crud', 'types'

		files = fs.readDirJsSync pathToMappers

		_.each files, (file, key, list) ->
			name = path.basename file, path.extname file
			crudKey = string.capitalize name

			self.types[crudKey] = require(join(pathToMappers, name))[crudKey]

		return @

exports = Crud

module.exports = exports
