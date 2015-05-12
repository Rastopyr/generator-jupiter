
renderPage = (type) ->
	(req, res, next) ->
		res.send 'hello 123'

successJSON = (data) ->
	(req, res, next) ->
		res.json
			success: true
			data: data

failureJSON = (data, code) ->
	code = code || 502

	(req, res, next) ->
		res.status(code).json
			success: false
			error: data

exports = {
	successJSON
	failureJSON
}

module.exports = exports
