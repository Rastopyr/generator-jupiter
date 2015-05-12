
should = require 'should'
Sequelize = require 'sequelize'

index = require '../../../../../../core/index'

SequelizeMaper = getLibrary('data/mapper/types/sequelize').Sequelize

getMapper = (options) ->
  options = options || {}

describe '#Data', ->
  describe '#Mapper', ->
    describe '#Sequelize', ->
      it 'should be instance of Sequelize', ->
        SequelizeMaper.should.have.property '__super__'
        SequelizeMaper.__super__.should.have.property 'Sequelize'
        SequelizeMaper.__super__.Sequelize.should.be.eql Sequelize
