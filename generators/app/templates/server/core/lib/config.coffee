
fs = require 'fs'
path = require 'path'

_ = require 'underscore'

class Config
	# Thanks to node-config creators
	getVal = (obj, property) ->
		isArr = if Array.isArray(property) then true else false
		elems = if isArr then property else property.split '.'
		name = elems[0]
		value = obj[name]

		if elems.length <= 1
			return value

		if typeof value is not 'object'
			return undefined

		getVal value, elems.slice 1

	resetConfig = (name) ->
		self = @

		@preloadConfigs name

	constructor: () ->
		@configDir = path.join pathes.app, 'config'
		@data = {}
		self = @

		@buildConfig()

		_.extend @, @data

		return @

	buildConfig: () ->
		@preloadConfigs()

	preloadConfigs: (name) ->
		self = @
		configDir = @configDir
		if name
			configFiles = [path.join @configDirm name]
		else
			configFiles = fs.readdirSync @configDir


		_.each configFiles, (item, key, list) ->
			if item.match ///^\.///
				return false

			configFile = require path.join configDir, item

			self.data = _.extend self.data, configFile

	get: (path) ->
		if not path
			return @data

		getVal.call @, @data, path

	reset: (name) ->
		name = name || ''

		resetConfig.call @, name

Config.class = Config

module.exports = exports = new Config
