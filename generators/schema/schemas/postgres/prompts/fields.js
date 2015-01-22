
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
    message: 'Add new field to Schema?',
    default: true
  },
  {
    name: 'name',
    type: 'input',
    message: 'Type name for new field',
    default: 'field-'+(new Date).getTime(),
    when: isAddNew
  },
  {
    name: 'allownull',
    type:'confirm',
    message: "Allow null in field?",
    default: false,
    when: isAddNew
  },
  {
    name:'type',
    type: 'list',
    message: 'Choose type of field',
    choices: [
      'STRING',
      'BOOLEAN',
      'TEXT',
      'DATE',
      'STRING.BINARY',
      'INTEGRE',
      'BIGINT',
      'FLOAT',
      'DECIMAL',
      'BLOB',
      'UUID'
    ],
    when: isAddNew
  },
  {
    name: 'unique',
    type: 'confirm',
    message: 'Field is unique?',
    default: false,
    when: isAddNew
  }, {
    name: 'correct',
    type: 'confirm',
    message: 'Fields is correct?',
    default: true,
    when: isAddNew
  }, {
    name: 'again',
    type: 'confirm',
    message: 'Add one more field?',
    default: true,
    when: function(results) {
      if(results.addnew) return true;

      return false;
    }
  }
];
