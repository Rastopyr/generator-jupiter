'use strict';

module.exports = [
  {
    name: 'actionup',
    message: 'Choose action of up for your migration',
    type: 'list',
    choices: [
      'addColumn',
      'changeColumn',
      'renameColumn',
      'removeColumn',
      'addIndex',
      'removeIndex',
      'createTable',
      'dropTable'
    ]
  }
];
