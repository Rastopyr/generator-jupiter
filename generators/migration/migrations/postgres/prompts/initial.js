
module.exports = [
  {
    name: 'format',
    type: 'list',
    message: 'Select fromat of migration file',
    choices: [
      'coffee'
    ]
  }, {
    name: 'name',
    type: 'input',
    message: 'Type name of your Migration',
    default: 'migration-' + (new Date()).getTime()
  }, {
    name: 'filename',
    type: 'input',
    message: 'Type filename of your Migration',
    default: 'migration-' + (new Date()).getTime()
  }, {
    name: 'relpath',
    type: 'input',
    message: 'Relative path, where Schema will be created',
    default: ''
  }, {
    name: 'correct',
    type: 'confirm',
    message: 'Name is correct? We can go to specify action?',
    default: true
  }
];
