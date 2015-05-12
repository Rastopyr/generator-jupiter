
View = getLibrary 'view'
PostgresAssocs = getApplication 'static/middleware/data/postgresAssocs'

middleware = (req, res, next) ->
	if not req.user
		err = new Error "Not authenticated"
		err.code = 401

		return View.failureJSON(err) req, res, next

	PostgresAssocs.successJSON({user: req.user}, 'user') req, res, next

module.exports = middleware
