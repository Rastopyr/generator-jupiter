
module.exports = [
  {
    name: 'name',
    type: 'input',
    message: 'Type name for new field',
    default: 'field-'+(new Date).getTime(),
  },
  {
    name: 'allownull',
    type:'confirm',
    message: "Allow null in field?",
    default: false,
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
  },
  {
    name: 'unique',
    type: 'confirm',
    message: 'Field is unique?',
    default: false,
  }, {
    name: 'correct',
    type: 'confirm',
    message: 'Fields is correct?',
    default: true,
  }, {
    name: 'again',
    type: 'confirm',
    message: 'Add one more field?',
    default: true,
  }
];
