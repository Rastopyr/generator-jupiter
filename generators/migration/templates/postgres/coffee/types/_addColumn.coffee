
up = (migration, DataTypes, done) ->
  migration.addColumn(
    "<%=table%>",
    "<%=column%>",
    DataTypes.<%=dataType%>
  ).done(done)

down = (migration, DataTypes, done) ->
  migration.removeColumn(
    "<%=table%>",
    "<%=column%>"
  ).done(done)

exports = {
  up
  down
}

module.exports = exports
