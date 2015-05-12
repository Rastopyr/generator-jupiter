
module.exports = [
  {
    name: 'databaseHost',
    type: 'input',
    message: 'Type host of database',
    default: 'database'
  },
  {
    name: 'databaseName',
    type: 'input',
    message: 'The name of database',
    default: 'database'
  },
  {
    name: 'databaseUserName',
    type: 'input',
    message: 'The name of user',
    default: 'admin'
  },
  {
    name: 'databaseUserPassword',
    type: 'input',
    message: 'The password for database access',
    default: 'password'
  }
];
