
path = require 'path'
fs = require 'fs'

_ = require 'lodash'
Sequelize = require 'sequelize'
should = require 'should'

index = require '../../../../../../../core/index'

Mapper = getLibrary 'core/data/mapper'
Pool = getLibrary 'core/data/mapper/pool'
Crud = getLibrary 'core/data/crud'

OptionsBuilder = getLibrary 'core/data/crud/types/sequelize/optionsBuilder'

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

createCrud = (options) ->
  opts =
    modelName: 'user'
    ctx: SequelizeMapper
    pool: SequelizePool

  new Crud 'Sequelize', _.merge opts, options

createBuilder = (options) ->
  crud = do createCrud

  new OptionsBuilder crud.model, options

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
      describe '#OptionsBuilder', ->

        it 'first level options object', ->
          builder = do createBuilder

          opts = builder.includeAccocs _.cloneDeep(testedOptions), SequelizePool.get 'user'

          props = ['where', 'attributes']

          _.each props, (prop) ->
            opts.should.have.property prop
            opts[prop].should.be.eql expectedOptions[prop]

          opts.should.be.have.property 'include'
          opts.include.length.should.be.eql 2

        it 'second level options object', ->
          builder = do createBuilder

          opts = builder.includeAccocs _.cloneDeep(testedOptions), SequelizePool.get 'user'

          _.each opts.include, (includeItem, keyOfInclude, includes) ->
            props = ['where', 'as', 'model']

            _.each props, (prop) ->
              includeItem.should.have.property prop
              includeItem[prop].should.be.eql expectedOptions.include[keyOfInclude][prop]
