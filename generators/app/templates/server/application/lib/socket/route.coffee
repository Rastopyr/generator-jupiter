
debug = require('debug') 'socket-route'

Handler = getLibrary 'socket/handler'

###
#	Expose `Route`
###

class Route
	constructor: (options) ->
		@.options = options

		@.path = options.path
		@.engine = options.engine

		@.options.pre = options.pre || []
		@.options.post = options.post || []

		debug 'new %s', @.path
	initLayer: (data, socket) ->
		layer = new Handler @.options

		layer.socket = socket

		layer.execHandlers data

		return layer

module.exports = Route

