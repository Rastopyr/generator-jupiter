
module.exports = {
  name: 'table',
  message: 'The table that will drop',
  type: 'input',
  default: 'table-' + (new Date()).getTime(),
  required: true
};
