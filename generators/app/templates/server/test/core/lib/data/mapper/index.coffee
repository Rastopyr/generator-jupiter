
should = require 'should'

index = require '../../../../../core/index'

Mapper = getLibrary 'data/mapper'
BaseMapper = getLibrary('data/mapper/types/base').Base

describe '#Data', ->
	describe '#Mapper', ->
		it 'should be a Function', ->
			Mapper.should.be.a.Function

		it 'should have preload function', ->
			Mapper.prototype.should.have.property 'preload'
			Mapper.prototype.preload.should.be.a.Function

		it 'should by default return instance of Base Mapper', ->
			mapper = new Mapper

			mapper.should.be.instanceof BaseMapper


