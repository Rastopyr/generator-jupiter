
path = require 'path'
url = require 'url'
request = require 'request'
crypto = require 'crypto'

fs = require 'fs-extra'
_ = require 'underscore'

jsExtensions = [
	'.js'
	'.coffee'
	'.json'
]

filterJsFiles = (files) ->
	_.filter files, (item, key, list) ->
		fileExt = path.extname item

		fileExt in jsExtensions

requireJsFile = (dir, file) ->
	fileExt = path.extname file

	if not fileExt in jsExtensions
		return false

	require path.join dir, file

requireJsFiles = (dir, files) ->
	requiredFiles = []

	_.each files, (item, key, list) ->
		if item = requireJsFile dir, item
			requiredFiles.push item

	return requiredFiles

readDirJs = (dir, callback) ->
	fs.readdir dir, (err, files) ->
		if err
			return callback err

		callback null, filterJsFiles files

readDirJsSync = (dir) ->
	files = fs.readdirSync dir

	filterJsFiles files

loadDirJs = (dir, callback) ->
	readDirJs dir, (err, files) ->
		if err
			return callback err

		returnedFiles = requireJsFiles dir, files

		callback null, returnedFiles

loadDirJsSync = (dir) ->
	files = readDirJsSync dir

	requireJsFiles dir, files

fetch = (sourceUrl, dest, callback) ->
	ext = path.extname sourceUrl
	solt = "#{Date.now()}"
	filename = crypto.createHash('md5').update(sourceUrl).update(solt).digest('hex')
	filePath = (path.join dest, filename) + ext
	sourceUrlParsed = url.parse sourceUrl
	sourceUrlParsed.uri = sourceUrlParsed.href

	returned = {}

	request.head sourceUrlParsed, (err, res, body) ->
		if err
			return callback err

		endCallback = () ->
			returned.path = filePath

			callback null, returned

		req = request(sourceUrlParsed)
			.pipe(fs.createWriteStream(filePath))
			.on('error', callback)
			.on('close', endCallback)
			# .end()

isJsFile = (name) ->
	jsExtensions.indexOf(path.extname(name))>-1

fs.readDirJs = readDirJs
fs.readDirJsSync = readDirJsSync
fs.loadDirJs = loadDirJs
fs.loadDirJsSync = loadDirJsSync
fs.fetch = fetch
fs.isJsFile = isJsFile

module.exports = exports = fs
