
View = getLibrary 'view'

middleware = (req, res, next) ->
	View.successJSON(user: req.user) req, res, next

module.exports = middleware
