
isAuth = require './isAuth'

middleware = (req, res, next) ->
	isAuth req, res, (err) ->
		return next err if err

		user = req.user

		if not user.isAdmin
			resp =
				redirectTo: '/admin/login'

			next resp

module.exports = middleware
