
class List
	constructor: () ->
		@items = []

		@objects = {}
	count: () ->
		@items.length
	get: (pointer) ->
		if 'string' is typeof pointer
			return @objects[pointer]

		if 'number' is typeof pointer
			return @objects[@items[pointer]]

		return null
	push: (name, item) ->
		if 'object' is typeof name
			item = name

			if not item.name
				name = @count()
			else
				name = item.name

		@objects[name] = item
		@items.push name
	remove: (pointer) ->
		index = null

		if 'object' is typeof pointer
			pointer = pointer.name

		if 'number' is typeof pointer
			index = pointer
			pointer = @items[index]

		delete @objects[pointer]

		if not index
			index =  @items.indexOf pointer

		if index > -1
			@items.splice index, 1

		return true
	removeAll: () ->
		@items = []
		@objects = {}

module.exports = List