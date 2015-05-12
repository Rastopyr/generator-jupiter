
should = require 'should'

index = require '../../../../../core/index'

Crud = getLibrary 'data/crud'
# BaseCrud = getLibrary('data/crud/types/base').Base

describe '#Data', ->
	describe '#Crud', ->
		it 'should be a Function', ->
			Crud.should.be.a.Function

		it 'should have preload function', ->
			Crud.prototype.should.have.property 'preload'
			Crud.prototype.preload.should.be.a.Function


	