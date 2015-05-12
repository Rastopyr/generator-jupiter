
_ = require 'underscore'
passport = require 'passport'

ConfigBase = getLibrary('config').get('base')
ConfigUrls = getLibrary('config').get('urls')
ConfigAuth = getLibrary('config').get('auth')

isAuth = (req) ->
	return req.isAuthenticated()

isAuthAdmin = () ->
	(req, res, next) ->
		if ConfigUrls.loginArray.indexOf req.path
			return next()

		if not isAuth req
			return res.redirect ConfigUrls.admin.getBaseUrl 'login'

		next()

authenticate = (strategy, lparams = {}) ->
	stratParams = _.extend ConfigAuth.strategies[strategy], lparams

	passport.authenticate strategy, stratParams

exports = {
	isAuth
	isAuthAdmin
	authenticate
}

module.exports = exports
