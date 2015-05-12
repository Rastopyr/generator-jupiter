
capitalize = (string) ->
	if spaceMatches = string.match /(\s|\S)/g
		string = string.replace /(\s|_)/g, '-'

	string.replace /(?:^|\s)\S/g, (a) ->
		a.toUpperCase()

exports.capitalize = capitalize

module.exports = exports
