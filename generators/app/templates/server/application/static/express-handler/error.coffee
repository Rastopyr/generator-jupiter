
View = getLibrary 'view'

handler = (err, req, res, next) ->
	if err not instanceof Error
		return View.failureJSON(err) req, res, next

	if err.code
		res.status err.code

	View.failureJSON(errors: err.message) req, res, next

module.exports = handler
