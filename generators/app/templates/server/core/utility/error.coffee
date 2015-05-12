
exports.throw = (msg, code) ->
	err = new Error
	err.message = msg
	err.code = code
	throw err

exports.new = (code) ->
	
