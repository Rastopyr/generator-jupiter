
path = require 'path'

resolve = () ->
	path.resolve path.join.apply path, arguments

module.exports =
	resolve: resolve
