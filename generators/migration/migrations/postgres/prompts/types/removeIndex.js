'use strict';
var chalk = require('chalk');

module.exports = [
  {
    name: 'table',
    message: 'Table that will remove index',
    type: 'input',
    default: 'table-' + (new Date()).getTime(),
    required: true
  },
  {
    name: 'columns',
    message: 'Enter the name of the columns that will remove index',
    banner: 'Type the attribute names separated by commas. At example: firstname,lastname' +
      chalk.dim('  Type the attribute names separated by commas.\n  At example: firstname,lastname') + '\n : ',
    type: 'input',
    required: true
  }
];
