
index = require '../../../core/index'
should = require 'should'

stringHelper = getUtility 'core/string'

describe '#Utility', ->
	describe '#String', ->
		it 'string should be capitalized', ->
			testedString = stringHelper.capitalize "testSttring"
			testedString.should.be.eql "TestSttring"

			testedString = stringHelper.capitalize "test_Sttring"
			testedString.should.be.eql "Test-Sttring"

			testedString = stringHelper.capitalize "test Sttring"
			testedString.should.be.eql "Test-Sttring"
