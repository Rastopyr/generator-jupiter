
Sequelize = require 'sequelize'

class SequelizeMapper extends Sequelize
  constructor: (options) ->
    super options.database, options.username, options.password, options.options

module.exports = exports = Sequelize: SequelizeMapper
