
function isAddNew(results) {
	if(results.addnew || results.again) {
		return true;
	}

	return false;
};

module.exports = [
	{
		name: 'addnew',
		type: 'confirm',
		message: 'Add new association to Schema?',
		default: true
	},
	{
		name: 'type',
		type: 'list',
		message: 'Choose type of association',
		choices: [
			'hasOne',
			'hasMany',
			'belongsTo',
			'belongsToMany'
		],
		when: isAddNew
	}, {
		name: 'model',
		type: 'input',
		message: 'Name of model, for association',
		required: true,
		when: isAddNew,
		required: true
	}, {
		name: 'as',
		type: 'input',
		message: 'Type name property, which will be specified in result of query',
		when: isAddNew
	}, {
		name: 'foreignKey',
		type: 'input',
		message: 'Type foreignKey name if nedded',
		when: isAddNew
	}, {
		name: 'otherKey',
		type: 'input',
		message: 'Type otherKey name if nedded',
		when: function(results) {
			var isAdd = isAddNew(results);

			if(results.type == 'belongsToMany' && isAdd) return true;

			return false
		}
	}, {
		name: 'through',
		type: 'input',
		message: 'Specify table name for ids, if nedeed',
		when: function(results) {
			var isAdd = isAddNew(results);

			if(results.type == 'belongsToMany' && isAdd) return true;

			return false
		}
	}, {
		name: 'correct',
		type: 'confirm',
		message: 'Associations is correct?',
		default: true,
		when: isAddNew
	}, {
		name: 'again',
		type: 'confirm',
		message: 'Add one more asociation?',
		default: false,
		when: function(results) {
			if(results.addnew) return true;

			return false;
		}
	}
];
