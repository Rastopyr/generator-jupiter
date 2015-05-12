
should = require 'should'
index = require '../../../../core/index'

List = getLibrary 'pattern/list'

describe '#Pattern', ->
	describe '#List', ->
		it 'should be a function', ->
			List.should.be.a.Function

		it 'should be create new instance', ->
			list = new List

			list.should.be.instanceof List

		it 'should be exist .items and .objects properties', ->
			list = new List

			list.should.have.property 'objects'
			list.should.have.property 'items'

		it '.objects should be Object', ->
			list = new List

			list.objects.should.be.Object

		it '.items should be Array', ->
			list = new List

			list.items.should.be.Array

		it 'value of key should compare value in objects', ->
			list = new List

			obj =
				a: 'b'

			list.push obj

			list.objects[list.items[0]].should.eql obj

		it 'get object by index', ->
			list = new List

			obj =
				a: 'b'

			list.push obj

			list.get(0).should.eql obj

		it 'get object by name', ->
			list = new List

			obj =
				a: 'b'

			list.push 'tested', obj

			list.get('tested').should.eql obj

		it 'remove object by name', ->
			list = new List

			obj =
				a: 'b'

			list.push 'tested', obj

			list.remove('tested').should.be.ok

			should(list.get('tested')).eql null

		it 'remove object by index', ->
			list = new List

			obj =
				a: 'b'

			list.push 'tested', obj
			list.remove(0).should.be.ok
			should(list.get(0)).eql null

		it 'remove all objects', ->
			list = new List

			obj = 
				a: 'b'

			list.push 'tested', obj
			list.push 'tested2', obj

			list.removeAll()

			list.items.length.should.be.eql 0
