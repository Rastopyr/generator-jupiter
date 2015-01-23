
module.exports = [
  {
    name: 'format',
    type: 'list',
    message: 'Select fromat of schema file',
    choices: [
      'coffee'
    ]
  },
  {
    name: 'schemaname',
    type: 'input',
    message: 'Type name of your Schema',
    default: 'schema-' + (new Date()).getTime()
  },
  {
    name: 'relpath',
    type: 'input',
    message: 'Relative path, where Schema will be created',
    default: ''
  }, {
    name: 'filename',
    type: 'input',
    message: 'Type filename of your Schema',
    default: 'schema-' + (new Date()).getTime()
  }, {
    name: 'correct',
    type: 'confirm',
    message: 'Name is correct? We can go to specify fields?',
    default: true
  }
];
