
func = (emitter, callback) ->
	emitter.locals.text = 'hello world'

	callback null, emitter

module.exports = exports = {
	func
}
