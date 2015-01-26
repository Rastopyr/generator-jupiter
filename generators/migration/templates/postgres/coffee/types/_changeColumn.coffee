
up = (migration, DataTypes, done) ->
  migration.changeColumn "<%=table%>", "<%=column%>", DataTypes.<%=dataType%>

  done()

down = (migration, DataTypes, done) ->
  done()

exports = {
  up
  down
}

module.exports = exports
