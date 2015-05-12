
_ = require 'underscore'
express = require 'express'

request = require 'supertest'
should = require 'should'

index = require '../../../../../core/index'

Server = getLibrary 'core/server'
Logger = getLibrary 'core/logger'

SingleServer = getLibrary 'server/types/single'
Router = getLibrary 'server/protos/router'

describe '#Server', ->
	describe '#Single', ->
		it 'should be instanceof baseServer instance', ->
			server = new Server

			server.should.be.instanceof Server

		it 'default server should be a Single server', ->
			server = new Server

			server.should.be.instanceof SingleServer

		it 'should have a logger', ->
			server = new Server

			server.should.have.property 'logger'
			server.logger.should.be.instanceof Logger.Logger

		it 'server router should be equal __proto__ of express.Router', ->
			server = new Server

			server.router.__proto__.should.eql express.Router

		it 'server .get should be chainible', ->
			server = new Server

			s = server
				.get('/', ->)
				.get('/helloworld', ->)

			s.should.be.eql server

		it 'server .post should be chainible', ->
			server = new Server

			s = server
				.post('/', ->)
				.post('/hellowrold', ->)

			s.should.be.eql server

		it 'server .get should process arguments to .router property', ->
			server = new Server

			route = ->

			server.get '/', route
			server.router.stack.length.should.be.ok
			_.some server.router.stack, (item, key, list) ->
				if not item.route
					return false

				_.some item.route.stack, (route) ->
					return route.handle == route || route.path == route

		it 'server .post should process arguments to .router property', ->
			server = new Server

			route = ->

			server.post '/', route
			server.router.stack.length.should.be.ok
			_.some server.router.stack, (item, key, list) ->
				if not item.route
					return false
				_.some item.route.stack, (route) ->
					return route.handle == route || route.path == route

		it 'server .set should be setting settings', ->
			server = new Server

			server.set 'option', 'value'
			option = server.get 'option'
			option.should.be.eql 'value'

		it 'server .get should be getting options', ->
			server = new Server

			server.set 'option', 'value'
			option = server.get 'option'
			option.should.be.eql 'value'

		it 'server .enable should be set options to true', ->
			server = new Server

			server.set 'option', false
			server.enable 'option'
			server.get('option').should.be.eql true

		it 'server .disable should be set options to false', ->
			server = new Server

			server.set 'option', true
			server.disable 'option'
			server.get('option').should.be.eql false

		it 'server .engine should be setting view engine', ->
			server = new Server

			ext = '.html'
			engine = ->

			server.engine '.html', engine
			server.express.engines[ext].should.be.eql engine

		it 'server should binding to port', (done) ->
			server = new Server

			testedString = 'testedString'

			route = (req, res) ->
				res.send testedString

			server
				.get('/', route)

			server.listen 3010, ->
				request(server.express)
					.get('/')
					.expect(testedString)
					.end done

		it 'server .all should be create all routes', (done) ->
			server = new Server
				override: true

			testedString = 'testedString'

			route = (req, res) ->
				res.send testedString

			server
				.all '/', route

			request(server.express)
				.get('/')
				.expect(testedString)
				.end (err, res) ->
					(err == null).should.be.ok

					request(server.express)
						.post('/')
						.expect(testedString)
						.end (err, res) ->
							(err == null).should.be.ok

							request(server.express)
								.put('/')
								.expect(testedString)
								.end (err, res) ->
									(err == null).should.be.ok

									request(server.express)
										.delete('/')
										.expect(testedString)
										.end done

		it 'server .locals should be eql express instance locals', () ->
			locals =
				email: 'rastopyr@gmail.com'

			server = new Server

			server.locals.email = 'rastopyr@gmail.com'

			should(server.express.locals).eql server.locals
			should(server.express.locals.email).eql locals.email

		it 'should return instance without new constructor', ->
			server = Server()

			server.should.instanceof Server

		describe 'Override methods', ->
			it 'execute .put should be trhowing', () ->
				server = new Server
				err = null

				try
					server.put(->)
				catch e
					err = e

				err.should.be.instanceof Error

			it 'execute .delete should be throwing', () ->
				server = new Server
				err = null

				try
					server.delete(->)
				catch e
					err = e

				err.should.be.instanceof Error

			it 'execute .put should be exist in router stack', () ->
				server = new Server
					override: true

				route = ->

				server
					.put('/', route)

				server.router.stack.length.should.be.ok
				_.some server.router.stack, (item, key, list) ->
					if not item.route
						return false

					_.some item.route.stack, (route) ->
						return route.handle == route || route.path == route

			it 'execute .delete should be exist in router stack', ->
				server = new Server
					override: true

				route = ->

				server
					.delete('/', route)

				server.router.stack.length.should.be.ok
				_.some server.router.stack, (item, key, list) ->
					if not item.route
						return false

					_.some item.route.stack, (route) ->
						return route.handle == route || route.path == route

			it 'PUT route should be executed and return tested string', (done) ->
				server = new Server
					override: true

				testedString = 'testedString'

				route = (req, res) ->
					res.send testedString

				server
					.put('/', route)

				request(server.express)
					.put('/')
					.expect(testedString)
					.end done

			it 'DELETE should be executed and return teseted string', (done) ->
				server = new Server
					override: true

				testedString = 'testedString'

				route = (req, res) ->
					res.send testedString

				server
					.delete('/', route)

				request(server.express)
					.delete('/')
					.expect(testedString)
					.end done

