
view = getLibrary 'view'

middleware = (data) ->
	(req, res, next) ->
		view.successJSON(data) req, res, next


module.exports = middleware
