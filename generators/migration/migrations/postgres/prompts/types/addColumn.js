'use strict';

module.exports = [
  {
    name: 'table',
    message: 'The table that will change column',
    type: 'input',
    default: 'table-' + (new Date()).getTime(),
    required: true
  }, {
    name: 'column',
    message: 'The column that will change',
    type: 'input',
    default: 'column-' + (new Date()).getTime(),
    required: true
  }, {
    name: 'dataType',
    message: 'Select DataType of created column',
    type: 'list',
    choices: [
      'STRING',
      'BOOLEAN',
      'TEXT',
      'DATE',
      'STRING.BINARY',
      'INTEGER',
      'BIGINT',
      'FLOAT',
      'DECIMAL',
      'BLOB',
      'UUID'
    ]
  }
];
