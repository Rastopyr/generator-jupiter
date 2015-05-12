
fs = require 'fs'
path = require 'path'

debug = require('debug') 'core:loader'
Promise = require 'bluebird'

_ = require 'lodash'
argv = require('optimist').argv

class Loader
	getEntityName = (bundle) ->
		ext = path.extname bundle
		name = path.basename bundle, ext

	getModuleNameFromArg = (item) ->
		if item.match 'module-not_'
			return item.replace 'module_not', ''

		if item.match 'module_'
			return item.replace 'module_', ''

	parseBundle = (args) ->
		if not args['bundle']
			err = new Error
			err.message = 'Not bundle exist'
			err.code = 'BNDLNEXT'
			throw err

		if typeof args['bundle'] is not 'string'
			err = new Error
			err.message = 'Bundle options must be strings'
			err.code = 'BNDLOPTNVLD'
			throw err

		if not @bundles[args['bundle']]
			err = new Error
			err.message = 'Loader have not bundle '+args['bundle']
			err.code = 'BNDLNFND'
			throw err

		@bundleName = args['bundle']

	parseModule = (args) ->
		self = @
		@moduleOptions = {}
		keys = Object.keys args

		_.each keys, (item, key) ->
			prefix = item.match ///(module-not_|module_)///

			if not prefix
				return false

			name = item.replace prefix[0], ''

			self.moduleOptions[name] = {}

			if prefix is 'module-not_'
				self.moduleOptions[name].load = false

	parseOptions = (args) ->
		keys = Object.keys args

		_.each keys, (item, key) ->
			prefix = item.match ///(option_)///

			return if not prefix

			moduleMatch = item.match ///option_(.*)_.*///

			return if not moduleMatch

			module = moduleMatch[1]
			valueNameMatch = item.match ///option_.*_(.*)///

			return if not valueNameMatch

			valueName = valueNameMatch[1]

			return if not valueName

			value = args[item]

			@.moduleOptions[module] = {} if not @.moduleOptions[module]
			@.moduleOptions[module][valueName] = value
		, @

	constructor: () ->
		@args = argv

		debug 'start parse modules'

		@bundlePath = path.join pathes.app, 'loader', 'bundle'
		@modulePath = path.join pathes.app, 'loader', 'module'

		debug 'start preload bundles'

		@preloadBundles()

		debug 'end preload bundles'
		debug 'start preload modules'

		@preloadModules()

		debug 'end preload bundles'

		@parseArgs()

		debug 'end parse modules'

		return @

	preloadBundles: () ->
		self = @
		bundlePath = @bundlePath
		bundles = {}

		_.each fs.readdirSync(bundlePath), (item, key) ->
			return if item.match ///^\.///

			stat = fs.statSync path.join bundlePath, item


			return if not stat.isFile()

			bundleName = self.bundleName = getEntityName item
			bundles[bundleName] = require path.join bundlePath, bundleName

		@bundles = bundles

	preloadModules: () ->
		self = @
		modulePath = @modulePath
		modules = {}

		_.each fs.readdirSync(modulePath), (item, key) ->
			return if item.match ///^\.///

			moduleName = getEntityName item
			debug 'require module: %s', moduleName
			modules[moduleName] = require path.join self.modulePath, moduleName

		@modules = modules

	parseArgs: (args) ->
		args = args || argv

		parseBundle.call @, args
		parseModule.call @, args
		parseOptions.call @, args

	start: () ->
		self = @

		modules = @.modules
		bundle = @.bundles[@bundleName]

		_.each @.moduleOptions, (module, name, list) ->
			bundle[name] = _.merge bundle[name] or {}, module

		options = bundle

		filteredOptions = _.filter options, (option, key, list) ->
			list[key].name = key

			option.active = option.active || 0

			return option.active

		sortedOptions = _.sortBy filteredOptions, (option, key, list) ->
			option.priority = option.priority || 0

			return option.priority

		Promise.reduce(sortedOptions, (index, option, key, length) ->
			module = modules[option.name]

			a = module.start option

			return a
		, 0)
			.then( ->
				console.log 'Loader is initialized'.green
			)

Loader.class = Loader

module.exports = exports = new Loader
