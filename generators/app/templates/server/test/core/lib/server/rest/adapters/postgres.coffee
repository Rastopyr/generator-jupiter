
should = require 'should'
_ = require 'underscore'

async = require 'async'

index = require '../../../../../../core/index'

Sequelize = require 'sequelize'

debug = require('debug') 'test:data:server:rest:postgres'

Crud = getLibrary 'data/crud'
Rest = getLibrary 'core/server/rest'

Mapper = getLibrary 'core/data/mapper'
Pool = getLibrary 'core/data/mapper/pool'

settedModel =
	schema:
		name:
			type: String
			required: true
	name: "User"
	options:
		tableName: "unit-test"
	type: "Postgres"

fixtureUser =
	name: 'Senin Roman'

PostgresMapper = new Mapper
	database: 'unittest'
	type: 'Postgres'
	username: 'testuser'
	password: 'testpassword'
	logging: false

PostgresPool = new Pool 
	type: 'Postgres'
	ctx: PostgresMapper

PostgresPool.set settedModel

crudOpts =
	modelName: 'User'
	ctx: PostgresMapper
	pool: PostgresPool

PostgresCrud = new Crud 'Postgres', crudOpts

restOpts =
	CRUD: PostgresCrud

getRest = () ->
	new Rest 'Postgres', restOpts

userPost = (callback) ->
	rest = getRest()

	rest.post fixtureUser, (err, user) ->
		return callback err if err

		callback err, user, rest

multipleUserPost = (callback) ->
	rest = getRest()

	singleName = _.singularize(rest.CRUD.model.name).toLowerCase()

	async.each [0..20], (key, next) ->
		rest.post fixtureUser, (err, payload) ->
			next null, payload[singleName]
	, (err, results) ->
		return callback err if err

		callback null, results, rest

props = []
methods = ['find', 'getOne', 'putOne', 'post', 'patchOne', 'deleteOne', 'http']

describe '#Server', ->
	describe '#Rest', () ->
		describe '#Postgres', ->
			afterEach (done) ->
				PostgresCrud.destroy done

			it 'should have REST methods', () ->
				rest = getRest()

				_.each methods, (prop) ->
					rest.should.have.property prop

			it '.post should be return setted model', (done) ->
				userPost (err, payload, rest) ->
					return done err if err

					payload.should.have.property PostgresCrud.model.name

					payload[PostgresCrud.model.name].should.be.instanceof Sequelize.Instance

					payload[PostgresCrud.model.name]
						.destroy()
						.done done

			it '.find should be return array of model', (done) ->
				multipleUserPost (err, userpayload, rest) ->
					return done err if err

					rootName = _.pluralize PostgresCrud.model.name

					rest.find (err, payload) ->
						return done err if err

						payload.should.have.property rootName
						payload[rootName].should.be.Array

						_.each payload[rootName], (model) ->
							model.should.be.instanceof Sequelize.Instance

						isCorrectLength = payload[rootName].length <= 10

						isCorrectLength.should.be.ok

						async.each payload[rootName], (model, next) ->
							model
								.destroy()
								.done next
						, done

			it '.find with limit `2` should be return 2 models', (done) ->
				multipleUserPost (err, userpayload, rest) ->
					return done err if err

					rootName = _.pluralize PostgresCrud.model.name

					rest.find {}, { limit: 2 }, (err, payload) ->
						return done err if err

						payload[rootName].should.be.Array

						isCorrectLength = payload[rootName].length == 2

						isCorrectLength.should.be.ok

						async.each payload[rootName], (model, next) ->
							model
								.destroy()
								.done next
						, done

			it '.find with offset should be return offseted models', (done) ->
				multipleUserPost (err, userpayload, rest) ->
					return done err if err

					rootName = _.pluralize PostgresCrud.model.name

					rest.find (err, payloadNotOffseted) ->

						rest.find {}, { offset: 1 }, (err, payload) ->
							return done err if err

							payload[rootName].should.be.Array
							payload[rootName][0].id.should.be.eql payloadNotOffseted[rootName][1].id

							rest.find (err, payload) ->
								return done err if err

								async.each payload[rootName], (model, next) ->
									model
										.destroy()
										.done next
								, done

			it '.findOne should return correct model', (done) ->
				userPost (err, user, rest) ->
					return done err if err

					rest.getOne user[PostgresCrud.model.name].id, (err, findedUser) ->
						return done err if err

						user[PostgresCrud.model.name].id
							.should.eql findedUser[PostgresCrud.model.name].id

						done()

			it '.post should be update model', (done) ->
				userPost (err, createdPayload, rest) ->
					return done err if err

					u = createdPayload[PostgresCrud.model.name]

					rest.putOne u.id, { name: 'Steve Jobs' }, (err, payload) ->
						return done err if err

						user = payload[PostgresCrud.model.name]

						user.name.should.eql 'Steve Jobs'
						user.id.should.eql u.id

						user
							.destroy()
							.done done

			it '.post should be remove model by query', (done) ->
				userPost (err, createdPayload, rest) ->
					return done err if err

					u = createdPayload[PostgresCrud.model.name]

					rest.deleteOne u.id, (err) ->
						return done err if err

						rest.getOne u.id, (err, payload) ->
							return done err if err

							should(payload[PostgresCrud.model.name]).be.eql null

							done()

