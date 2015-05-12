
midlleware = (req, res, next) ->
	if req.isAuthenticated()
		return next()

	error = new Error 'You should be authenticated'

	error.code = 401

	next done error

module.exports = middleware
