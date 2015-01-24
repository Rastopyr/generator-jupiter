'use strict';

module.exports = [
  {
    name: 'table',
    message: 'Table that will remove column',
    type: 'input',
    default: 'table-' + (new Date()).getTime(),
    required: true
  },
  {
    name: 'column',
    message: 'The column that will remove',
    type: 'input',
    default: 'column-' + (new Date()).getTime(),
    required: true
  },
  {
    name: 'dataType',
    message: 'Select DataType of remove column',
    type: 'list',
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
    ]
  }
];
