
should = require 'should'

index = require '../../../../../../core/index'

Pool = getLibrary 'data/mapper/pool'

describe '#Data', ->
	describe '#Mapper', ->
		describe '#Pool', ->
			it 'should be a Function', ->
				Pool.should.be.a.Function

			it 'should have preload function', ->
				Pool.prototype.should.have.property 'preload'
				Pool.prototype.preload.should.be.a.Function

