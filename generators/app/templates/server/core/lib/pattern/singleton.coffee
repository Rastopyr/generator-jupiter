
class Singleton
	constructor: (constructor) ->
		@constructor = constructor
		@instance = null
		return @
	get: (args..., isNew) ->
		if not isNew and 'boolean' is typeof arguments[0]
			isNew = arguments[0]

		if isNew
			return new @constructor args...

		@instance ?= new @constructor args...

exports = Singleton

module.exports = exports
