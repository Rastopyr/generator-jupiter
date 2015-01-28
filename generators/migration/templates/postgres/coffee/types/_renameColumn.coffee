
up = (migration, DataTypes, done) ->
  migration.renameColumn(
    "<%=table%>",
    "<%=attrNameBefore%>",
    "<%=attrNameAfter%>"
  ).done(done)

down = (migration, DataTypes, done) ->
  migration.renameColumn(
    "<%=table%>",
    "<%=attrNameAfter%>",
    "<%=attrNameBefore%>"
  ).done(done)

exports = {
  up
  down
}

module.exports = exports
