'use strict';

module.exports = [
  {
    name: 'table',
    type: 'input',
    message: 'The table that will column that will renamed',
    default: 'table-' + (new Date()).getTime()
  }, {
    name: 'attrNameBefore',
    type: 'input',
    message: 'The column that will before renamed',
    default: 'column-' + (new Date()).getTime()
  }, {
    name: 'attrNameAfter',
    type: 'input',
    message: 'The column that will after renamed',
    default: 'column-' + (new Date()).getTime()
  }
];
