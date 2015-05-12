
express = require 'express'

Server = getLibrary 'server'

routes = () ->
	@get '/', (req, res) ->
		res.send 'Hello world'

module.exports = exports = 
	start: (options) ->
		options =
			app: express
			port: options.port
			routes: routes

		server = new Server options
		server.listen()
		
