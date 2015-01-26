
up = (migration, DataTypes, done) ->
  migration.removeColumn "<%=table%>", "<%=column%>"

  done()

down = (migration, DataTypes, done) ->
  sequelize.addColumn "<%=table%>", "<%=column%>", DataTypes.<%=dataType%>
migration
  done()

exports = {
  up
  down
}

module.exports = exports
