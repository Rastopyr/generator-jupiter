'use strict';

var table = {
  name: 'table',
  message: 'The table that will create',
  type: 'input',
  default: 'table-' + (new Date()).getTime(),
  required: true
};

var fields = [
  {
    name: 'name',
    type: 'input',
    message: 'Type name for new field',
    default: 'field-' + (new Date()).getTime(),
  }, {
    name: 'allownull',
    type: 'confirm',
    message: 'Allow null in field?'
  }, {
    name: 'type',
    type: 'list',
    message: 'Choose type of field',
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
    ],
  }, {
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

var options = [
  {
    name: 'chooseengine',
    message: 'Select engine?',
    type: 'confirm',
    default: true
  }, {
    name: 'enginename',
    message: 'Choose engine for table',
    type: 'list',
    default: 'InnoDB',
    choices: [
      'MYISAM',
      'InnoDB',
      'NDB Cluster'
    ],
    when: function (results) {
      return results.chooseengine;
    }
  }
];

exports = {
  table: table,
  fields: fields,
  options: options
};

module.exports = exports;
