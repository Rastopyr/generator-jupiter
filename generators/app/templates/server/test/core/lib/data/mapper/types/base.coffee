
should = require 'should'

index = require '../../../../../../core/index'

BaseMapper = getLibrary('data/mapper/types/base').Base

describe '#Data', ->
	describe '#Mapper', ->
		describe '#Base', ->
			it 'should be a function', ->
				BaseMapper.should.be.a.Function

			it 'should be have connect function', ->
				base = new BaseMapper

				base.should.have.property 'connect'
