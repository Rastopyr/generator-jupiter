
module.exports = [
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
  }, {
    name: 'model',
    type: 'input',
    message: 'Name of model, for association',
    required: true,
  }, {
    name: 'as',
    type: 'input',
    message: 'Type name property, which will be specified in result of query',
  }, {
    name: 'foreignKey',
    type: 'input',
    message: 'Type foreignKey name if nedded',
  }, {
    name: 'otherKey',
    type: 'input',
    message: 'Type otherKey name if nedded',
    when: function (results) {
      if (results.type === 'belongsToMany') {
        return true;
      }

      return false;
    }
  }, {
    name: 'through',
    type: 'input',
    message: 'Specify table name for ids, if nedeed',
    when: function (results) {
      if (results.type === 'belongsToMany') {
        return true;
      }

      return false;
    }
  }, {
    name: 'correct',
    type: 'confirm',
    message: 'Associations is correct?',
    default: true,
  }, {
    name: 'again',
    type: 'confirm',
    message: 'Add one more asociation?',
    default: false
  }
];
