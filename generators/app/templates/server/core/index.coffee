
path = require 'path'

argv = require('optimist').argv

relRootDir = path.resolve path.join __dirname, '../../'

###
	Create global path to #global module
###

global.entityPath = path.resolve path.join relRootDir, 'server/core/entity'

###
	Initialization global Entity namespace
###
require entityPath

###
	Initialization global Config
###

Config = getLibrary 'core/config'

global.Config = Config

###
	Initialization loader
###

if not argv.isTest
	Loader = getLibrary 'loader'
	Loader.start()
