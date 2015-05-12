
path = require 'path'
fs = require 'fs'

_ = require 'lodash'
Sequelize = require 'sequelize'
should = require 'should'

index = require '../../../../../../core/index'

Mapper = getLibrary 'core/data/mapper'
Pool = getLibrary 'core/data/mapper/pool'
Crud = getLibrary 'core/data/crud'

adminModel =
  schema:
    name:
      type: Sequelize.STRING
      notNull: true
  name: 'user'
  type: 'Sequelize'
  options:
    tableName: 'unit-test-users'
    associations: [
      modelName: 'type'
      as: 'type'
      assocType: 'belongsTo'
    ,
      modelName: 'status'
      as: 'status'
      assocType: 'belongsTo'
    ]

typeModel =
  schema:
    name:
      type: Sequelize.STRING
      allowNull: false
  name: 'type'
  type: 'Sequelize'
  options:
    tableName: 'unit-test-type'
    associations: [
      modelName: 'permission'
      as: 'permissions'
      assocType: 'belongsToMany'
    ]

statusModel =
  schema:
    name:
      type: Sequelize.STRING
      allowNull: false
  type: 'Sequelize'
  name: 'status'
  options:
    tableName: 'unit-test-status'

permissionModel =
  schema:
    name:
      type: Sequelize.STRING
      allowNull: false
  type: 'Sequelize'
  name: 'permission'
  options:
    tableName: 'unit-test-permissions'

SequelizeMapper = new Mapper
  type: 'Postgres'
  database: 'unittest'
  username: 'testuser'
  password: 'testpassword'
  logging: false

SequelizePool = new Pool
  type: 'Sequelize'
  ctx: SequelizeMapper

SequelizePool.set permissionModel
SequelizePool.set statusModel
SequelizePool.set typeModel
SequelizePool.set adminModel

console.log SequelizeMapper.models['type']

createCrud = (options) ->
  opts =
    modelName: 'user'
    ctx: SequelizeMapper
    pool: SequelizePool

  new Crud 'Sequelize', _.merge opts, options

testedOptions =
  where:
    id: 1
    status:
      id: 2
    type:
      id: 3
      permissions: id: [1, 2]
  attributes: [
    status: ['id']
  ,
    type: [ 'id']
  , 'id', 'name'
  ]

expectedOptions =
  where: id: 1
  attributes: ['id', 'name']
  include: [
    association: SequelizePool.get('user').associations['type']
    where: id: 3
    as: 'type'
    model: SequelizePool.get('type')
    include: [
      association: SequelizePool.get('type').associations['permissions']
      where: id: [1, 2]
      attributes: []
      through: attributes: []
    ]
  ,
    association: SequelizePool.get('user').associations['status']
    where: id: 2
    as: 'status'
    model: SequelizePool.get('status')
    include: []
  ]

describe '#Data', () ->
  describe '#Crud', ()->
    describe '#Sequelize', ->
      before (done) ->
        SequelizeMapper.drop()
          .catch((err)->
            console.log typeof err
            do done false
          ).then(->
            SequelizeMapper.sync()
          ).then ->
            do done

      afterEach (done) ->
        crud = do createCrud

        crud.destroy(truncate: true)
          .then -> do done

      it 'should have methods', () ->
        crud = do createCrud

        methods = [
          'findAll'
          'findOne'
          'findAndCount'
          'count'
          'create'
          'destroy'
          'bulkCreate'
          'excludeAttributes'
          'prettyResponse'
          'prettyResponseByAssoc'
        ]

        _.each methods, (method) ->
          crud.should.have.property(method)

          crud[method].should.be.a.Function

      describe '.methods', ->
        it '.findAll', (done) ->
          crud = do createCrud

          crud.create(
            name: 'Roman'
          ).then( ->
            crud.findAll().then( (users) ->
              users.should.be.instanceof Array
              users.length.should.eql 1

              user = _.first(users)
              user.should.have.property 'name'
              user.name.should.be.eql 'Roman'
            ).then -> do done
          )

        it '.findOne', (done) ->
          crud = do createCrud

          crud.create(
            name: 'Roman'
          ).then( ->
            crud.findOne().then( (Roman) ->
              Roman.should.be.instanceof Object
              Roman.should.be.instanceof Sequelize.Instance

              Roman.should.have.property 'name'
              Roman.name.should.be.eql 'Roman'
            ).then -> do done
          )

        it '.findAndCount', (done) ->
          crud = do createCrud

          crud.create(
            name: 'Roman'
          ).then( ->
            crud.findAndCount().then( (response) ->
              response.should.be.instanceof Object
              response.should.have.property 'count'
              response.should.have.property 'rows'

              response.rows.length.should.be.eql 1
              response.count.should.be.eql 1

              Roman = _.first response.rows

              Roman.should.have.property 'name'
              Roman.name.should.be.eql 'Roman'
            ).then -> do done
          )

      after (done) ->
        SequelizeMapper.drop().catch((err) ->
          done err
        ).then(->
          do done
        )
