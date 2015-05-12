
path = require 'path'

_ = require 'underscore'
should = require 'should'
request = require 'request'

index = require '../../../core/index'

fs = getLibrary 'core/fs'

testedArgs =
	_: []
	bundle: 'test'
	# module_express: true
	module_rest: true
	# option_express_port: 3003
	options_rest_port: 3008

expressModuleName = "express#{(new Date()).getTime()}.coffee"

testedArgs[expressModuleName] =
	active: true

testedArgs['option_'+expressModuleName+'_port'] = 3003

bundlePath = path.join pathes.server, 'test', 'loader', 'bundle', 'test.coffee'
modulePath = path.join pathes.server, 'test', 'loader', 'module', 'express.coffee'

writedBundlePath = path.join pathes.app, 'loader', 'bundle', 'test.coffee'
writedModulePath = path.join pathes.app, 'loader', 'module', expressModuleName

fs.linkSync bundlePath, writedBundlePath
fs.linkSync modulePath, writedModulePath

Loader = getLibrary 'core/loader'

describe '#Loader.parse', () ->
	it '#Loader should exists', () ->
		should(Loader).exist

	it 'should be parse test bundle', () ->
		should(Loader.bundles.test).exist

	it 'should parse modules modules after set argv', () ->
		Loader.parseArgs testedArgs
		should(Loader.bundleName).exist
		should(Loader.bundleName).eql 'test'

	it '#Loader.moduleOptions', () ->
		Loader.parseArgs testedArgs
		should(Loader.moduleOptions[expressModuleName]).not.eql undefined
		should(Loader.moduleOptions[expressModuleName].port).eql testedArgs["option_#{expressModuleName}_port"]

	it '#Loader.modules.start should be a function', () ->
		modules = Loader.modules

		_.each modules, (module, key, list) ->
			should(module.start).be.a.Function



after ()->
	fs.unlinkSync writedBundlePath
	fs.unlinkSync writedModulePath
