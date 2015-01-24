'use strict';
var chalk = require('chalk');

module.exports = [
  {
    name: 'table',
    message: 'The table that will add index',
    type: 'input',
    default: 'table-' + (new Date()).getTime(),
    required: true
  }, {
    name: 'columns',
    message: 'Enter the name of the columns that will indexed. \n' +
      chalk.dim('  Type the attribute names separated by commas.\n  At example: firstname,lastname') + ' \n : ',
    type: 'input',
    required: true
  }
];
