
url = require 'url'
path = require 'path'
join = path.join

_ = require 'underscore'

Crud = getLibrary 'core/data/crud'
fs = getLibrary 'core/fs'
error = getUtility 'core/error'
string = getUtility 'core/string'

class RestResponse
	constructor: (res, next) ->
		@.res = res
		@.next = next
	success: (data) ->
		console.time '1'

		@.res.req.on 'end', ->
			console.timeEnd '1'

		@send 200,
			success: true
			data: data

	error: (err) ->
		response = 
			success: false
			err: err.message || err

		if err.code
			response.code = err.code

		@.send 200, response
	send: (code, data) ->
		@.res.setHeader 'Content-Type', 'application/json'

		if @.next and @.next.arguments
			@.res.locals.restData = data

			return @.next()

		@.res.send data 

class REST
	constructor: (type, options) ->
		if not options and 'object' is typeof type
			options = type
			type = ''

		if options.type and not type
			type = options.type

		if options.CRUD
			@CRUD = options.CRUD

		if not options.CRUD and type
			options.type = type
			@CRUD = new Crud type, options

		if options.response is 'payload'
			@.payload = true

		if not options.CRUD and not type
			error.throw 'CRUD or type of CRUD not exist', "CRUDNEXISTINREST"

		@preloadAdapters()

		if not @types[type]
			error.throw 'REST adapter or type of adapter not exist', "ADPTRNEXISTINREST"

		@__proto__ = _.extend @__proto__, @types[type]

		return @
	preloadAdapters: () ->
		self = @
		self.types = {}
		pathToTypes = join pathes.core, 'lib/server/rest', 'adapters'

		files = fs.readDirJsSync pathToTypes

		_.each files, (file, key, list) ->
			name = path.basename file, path.extname file
			typeKey = string.capitalize name

			self.types[typeKey] = require(join(pathToTypes, name))[typeKey]

		return @
	http: (options) ->
		@.options = options || {}

		(req, res, next) =>
			reqUrl = url.parse req.url
			reqMethod = req.method.toLowerCase()
			isOne = reqUrl.pathname.split('/')

			query = {}
			body = {}

			params = _.clone req.query

			if params.selector
				query = _.clone params.selector
				delete params.selector

			if req.body
				body = req.body

			if isOne.length
				if isOne.length > 2
					return next()

				id = Array.prototype.slice.call(isOne, 1, 2).pop()

			method = "#{reqMethod}#{if id then 'One' else ''}"

			done = (err, data) ->
				response = new RestResponse res, next

				if err
					return response.error err

				response.success data

			switch method
				when 'get' then return @.find query, params, done
				when 'getOne' then return @.getOne id, params, done
				when 'post' then return @.post req.body, params, done
				when 'putOne' then return @.put id, req.body, params, done
				when 'patchOne' then return @.patch id, req.body, params, done
				when 'deleteOne' then return @.deleteOne id, done

exports = REST
exports.RestResponse = RestResponse

module.exports = exports
