path = require 'path'
fs = require 'fs'

_ = require 'lodash'
Sequelize = require 'sequelize'
should = require 'should'

index = require '../../../../../../../core/index'

Mapper = getLibrary 'core/data/mapper'
Pool = getLibrary 'core/data/mapper/pool'
Crud = getLibrary 'core/data/crud'

Prettyfier = getLibrary 'core/data/crud/types/sequelize/prettyResponse'

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
      modelName: 'unttype'
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
  name: 'unttype'
  type: 'Sequelize'
  options:
    tableName: 'unit-test-type'
    # associations: [
    #   modelName: 'permission'
    #   as: 'permissions'
    #   assocType: 'belongsToMany'
    # ]

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

createCrud = (options) ->
  opts =
    modelName: 'user'
    ctx: SequelizeMapper
    pool: SequelizePool
    isPrettyReponse: true
    isIncludeAccocs: true

  new Crud 'Sequelize', _.merge opts, options

createPrettifier = (options) ->
  crud = do createCrud

  new Prettyfier crud.model, options

describe '#Data', () ->
  describe '#Crud', ()->
    describe '#Sequelize', ->
      describe '#Prettyfier', ->

        before (done) ->
          SequelizeMapper.drop()
            .catch((err)->
              console.log typeof err
              do done false
            ).then(->
              SequelizeMapper.sync()
            ).then ->
              do done

        it 'should return simple Object', (done) ->
          crud = do createCrud

          crud.create(name: 'Roman')
            .then (user) ->
              user.createType(name: 'default')
                .then (type) ->
                  crud.findOne(
                    where:
                      id: user.id
                      type: id: type.id
                    attributes: [
                      'id', 'name'
                    ,
                      'type': [
                        'id',
                      ]
                    ]
                  ).then (user) ->
                    user.should.be.eql
                      type: id: 1
                      name: 'Roman'
                      id: 1

                    do done

        after (done) ->
          SequelizeMapper.drop().catch((err) ->
            done err
          ).then(->
            do done
          )
