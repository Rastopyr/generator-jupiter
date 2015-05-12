
should = require 'should'

index = require '../../../../core/index'

Server = getLibrary 'core/server'

describe '#Server', () ->
	it 'should be a Function', ->
		Server.should.be.Function
