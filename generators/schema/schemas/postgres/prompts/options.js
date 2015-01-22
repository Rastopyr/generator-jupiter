
module.exports = [
  {
    name: 'tableName',
    type: 'input',
    message: 'Type name of table for schema',
    default: 'table-'+(new Date()).getTime()
  },
  {
    name: 'timestamps',
    type: 'confirm',
    message: 'Add timestamps to schema?',
    default: true
  },
  {
    name: 'paranoid',
    type: 'confirm',
    message: 'Add `deletedAt` property to schema?',
    default: function(results) {
      if(!results.timestamps) return false

      return true;
    },
    when: function(results) {
      if(!results.timestamps) return false

      return true;
    }
  },
  {
    name: 'underscored',
    type: 'confirm',
    message: 'Use underscored defenition?',
    default: false
  }, {
    name: 'correct',
    type: 'confirm',
    message: 'Options is correct?',
    default: true
  }
];
