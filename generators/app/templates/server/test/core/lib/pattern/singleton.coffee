
should = require 'should'
index = require '../../../../core/index'

Singleton = getLibrary 'pattern/singleton'

class A

describe '#Pattern', ->
	describe '#Singleton', ->
		it 'should be a function', ->
			Singleton.should.be.a.Function

		it 'should be return a new Class instance', ->

			singleton = new Singleton A
			instance = singleton.get()
			instance.should.be.instanceof A

		it 'returned instance should be eql cached instance', ->
			singleton = new Singleton A
			instance = singleton.get()
			instance.should.be.eql singleton.instance

		it 'returned instance should be not eql cached instance', ->
			singleton  = new Singleton A
			instance = singleton.get true
			instance.should.be.instanceof A
			instance.should.be.not.eql singleton.instance
		
