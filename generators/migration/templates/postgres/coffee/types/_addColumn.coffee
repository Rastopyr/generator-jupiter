
up = (migration, DataTypes, done) ->
  migration.addColumn "<%=table%>", "<%=column%>", DataTypes.<%=dataType%>

  done()

down = (migration, DataTypes, done) ->
  migration.removeColumn "<%=table%>", "<%=column%>"
  done()

exports = {
  up
  down
}

module.exports = exports
