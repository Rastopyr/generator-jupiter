
path = require 'path'
join = path.join

winston = require 'winston'
capitalize = require('winston/lib/winston/common').capitalize

fs = getLibrary 'core/fs'

transports = exports

fs.readdirSync(join(__dirname, 'transports')).forEach (transport, kt) ->
	transport = capitalize transport.replace '.coffee', ''

	transports.__defineGetter__ transport, () ->
		return require './transports/'+transport[transport]
