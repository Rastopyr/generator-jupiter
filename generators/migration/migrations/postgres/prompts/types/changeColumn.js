'use strict';

module.exports = [
  {
    name: 'table',
    message: 'Table that will add changed',
    type: 'input',
    default: 'table-' + (new Date()).getTime(),
    required: true
  }, {
    name: 'column',
    message: 'The column that will changed',
    type: 'input',
    default: 'column-' + (new Date()).getTime(),
    required: true
  }, {
    name: 'dataType',
    message: 'Select DataType of changed column',
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
