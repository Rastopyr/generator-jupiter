'use strict';

module.exports = [
  {
    name: 'actionup',
    message: 'Choose action of up for your migration',
    type: 'list',
    choices: [
      'createTable',
      'dropTable',
      'addColumn',
      'changeColumn',
      'removeColumn',
      'addIndex',
      'removeIndex'
      // 'addConstraint',
      // 'removeConstraint',
    ]
  }
  // , {
  //   name: 'actiondown',
  //   message: 'Choose action of down for your migration',
  //   type: 'list',
  //   choices: [
  //     'createTable',
  //     'addColumn',
  //     'changeColumn',
  //     'removeColumn',
  //     'addIndex',
  //     'removeIndex',
  //     'addConstraint',
  //     'removeConstraint',
  //     'dropTable'
  //   ]
  // }, {
  //   name: 'tablename',
  //   message: 'Type name of table',
  //   required: true
  // }
];
