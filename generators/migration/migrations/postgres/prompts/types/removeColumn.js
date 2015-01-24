'use strict';

module.exports = [
  {
    name: 'table',
    message: 'Enter the name of the table that will remove column',
    type: 'input',
    required: true
  },
  {
    name: 'column',
    message: 'Enter the name of the column that will remove',
    type: 'input',
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
