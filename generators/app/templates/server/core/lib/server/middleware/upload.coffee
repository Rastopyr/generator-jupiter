
path = require 'path'
join = path.join

multer = require 'multer'
_ = require 'underscore'

fs = getLibrary 'fs'

middleware = (options) ->
	options = options || {}

	multOptions =
		dest: join pathes.base, 'static/uploads'
		relDest: ''

	options = _.extend multOptions, options

	if options.relDest
		options.dest = join options.dest, options.relDest

	fs.ensureDirSync options.dest

	options.onParseEnd = (req, next) ->
		if options.field
			req.body[options.field] = req.files[options.field].name

		next()

	(req, res, next) ->

		multerMiddle = multer options

		multerMiddle.apply multerMiddle, arguments

exports = middleware

module.exports = exports
