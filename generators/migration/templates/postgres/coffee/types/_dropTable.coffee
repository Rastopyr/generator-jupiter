
up = (sequelize, DataTypes, done) ->
  sequelize.dropTable "<%=table%>"

  done()

down = (sequelize, DataTypes, done) ->
  done()

exports = {
  up
  down
}

module.exports = exports
