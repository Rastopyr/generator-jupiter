
_ = require 'lodash'

async = require 'async'
Sequelize = require 'sequelize'

Scopes = Config.get 'scopes'

debug = require('debug') 'data:server:rest:postgres'

getRootName = (isArray, model) ->
	if isArray
		return _.pluralize model.name
	
	return model.name

buildDataRelation = (data, model, d) ->
	sequelize = model.options.sequelize

	_.each model.associations, (assoc, key) ->
			return if assoc.associationType is 'BelongsToMany'

			return if not data[assoc.target.name]

			name = assoc.target.options.name.singular
			plural = assoc.target.options.name.plural
			_plural = '_'+assoc.target.options.name.plural

			if d[name] and d[name] not instanceof Array
				d[_plural] = {}
				d[_plural][d[name].id] = d[name]

				if data[assoc.as]
					if not d[_plural][data[name].id]
						d[_plural][data[name].id] = data[assoc.as]

				delete d[name]

			else if d[_plural]
				if not d[_plural][data[name].id]
					d[_plural][data[name].id] = data[assoc.as]
			else
				d[name] = data[assoc.as]

			if d[_plural]
				d[plural] = _.values d[_plural]
				delete d[_plural]

			if _.keys(assoc.target.associations).length
				if d[plural]
					_.each d[plural], (d2) ->
						buildDataRelation d2, sequelize.models[name], d

				if d[name]
					buildDataRelation d[name], sequelize.models[name], d

	return d

buildDataRelations = (data, model, d)->
	if not _.isArray data
		return buildDataRelation data, model, d

	_.each data, (item, key) ->
		buildDataRelation item, model, d

	return d

prepareResponse = (data, meta) ->
	isArray = _.isArray data
	rootName = getRootName isArray, @.model

	d = {}
	d[rootName] = data
	if meta
		d.meta = meta

	buildDataRelations data, @.model, d

preparePayload = (data) ->
	model = @.model

	d = data[model.name]

	return d

clojure =
	count: (query, next) ->
		@.CRUD.count query, next
	post: (payload, callback) ->
		@CRUD.create payload, callback
	find: (query, options, callback) ->
		lscopes = Scopes[@.CRUD.model.name]

		if lscopes
			if lscopes.where
				query = _.extend query, lscopes.where

			if lscopes.options
				options = _.extend options, lscopes.options

		@CRUD.find query, options, callback
	findOne: (query, options, callback) ->
		lscopes = Scopes[@.CRUD.model.name]

		if lscopes
			if lscopes.where
				query = _.extend query, lscopes.where

			if lscopes.options
				options = _.extend options, lscopes.options

		@CRUD.findOne query, options, callback
	update: (query, values, options, callback) ->
		@CRUD.update query, values, options, callback
	destroy: (query, options, callback) ->
		@CRUD.destroy query, options, callback

find = (query, options, callback) ->
	if 'function' is typeof query
		callback = query
		query = {}
		options = {}

	if 'function' is typeof options
		callback = options
		options = {}

	options.limit = options.limit || 10
	options.offset = options.offset || 0

	async.parallel
		d: (next) =>
			clojure.find.call @, query, options, next
		m: (next) =>
			clojure.count.call @, query, next
	, (err, res) =>
		return callback err if err

		d = prepareResponse.call @.CRUD, res.d,
			count: res.m

		callback null, d

getOne = (id, options, callback) ->
	if 'function' is typeof id
		error.throw "Id not exist in REST GET query", "IDNTEXSTINRESTGET"

	if 'function' is typeof options
		callback = options
		options = {}

	query =
		id: id

	clojure.findOne.call @, query, options, (err, result) =>
		return callback err if err

		d = prepareResponse.call @.CRUD, result

		callback null, d

patchOne = (id, values, options, callback) ->
	if 'function' is typeof id
		error.throw "Id not exist in REST PUT query", "IDNTEXSTINRESTPUT"

	if 'function' is typeof options
		callback = options
		options = {}

	query =
		id: id

	clojure.update.call @, query, values, options, (err, result) =>
		return callback err if err

		clojure.findOne.call @, query, options, (err, result) =>
			return callback err if err

			d = prepareResponse.call @.CRUD, result

			callback null, d

post = (data, options, callback) ->
	if 'function' is typeof options
		callback = options
		options = {}

	data = preparePayload.call @.CRUD, data

	clojure.post.call @, data, (err, result) =>
		return callback err if err

		d = prepareResponse.call @.CRUD, result

		callback null, d

deleteOne = (id, options, callback) ->
	if 'function' is typeof options
		callback = options
		options = {}

	query =
		id: id

	clojure.destroy.call @, query, options, (err, result) =>
		return callback err if err

		d = prepareResponse.call @.CRUD, result

		callback null, d

# put = 
putOne = put = patchOne

filter = {
	find
	post
	put
	getOne
	putOne
	patchOne
	deleteOne
	prepareResponse
	buildDataRelations
}

exports.Postgres = filter

module.exports = exports
