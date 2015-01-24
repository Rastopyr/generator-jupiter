
module.exports = [
  {
    name: 'format',
    type: 'list',
    message: 'Select fromat of Fixture file',
    choices: [
      'coffee'
    ]
  }, {
    name: 'ftype',
    type: 'list',
    message: 'Select type of Fixture data',
    choices: [
      'single', 'multiple'
    ]
  }, {
    name: 'name',
    type: 'input',
    message: 'Type name of your Fixture',
    default: 'fixture-' + (new Date()).getTime()
  }, {
    name: 'filename',
    type: 'input',
    message: 'Type filename of your Fixture',
    default: 'fixture-' + (new Date()).getTime()
  }, {
    name: 'relpath',
    type: 'input',
    message: 'Relative path, where Schema will be created',
    default: ''
  }, {
    name: 'correct',
    type: 'confirm',
    message: 'Options is correct?',
    default: true
  }
];
