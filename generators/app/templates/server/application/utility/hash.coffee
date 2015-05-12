
crypto = require 'crypto'

md5 = (string) ->
	crypto
		.createHash('md5')
		.update(string)
		.digest('hex')

exports = {
	md5
}

module.exports = exports
