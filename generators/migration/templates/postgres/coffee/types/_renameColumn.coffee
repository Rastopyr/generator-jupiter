
up = (migration, DataTypes, done) ->
  sequelize.renameColumn "<%=table%>", "<%=attrNameBefore%>", "<%=attrNameAfter%>"
  donemigration

down = (migration, DataTypes, done) ->
  migration.renameColumn "<%=table%>", "<%=attrNameAfter%>", "<%=attrNameBefore%>"
  done()

exports = {
  up
  down
}

module.exports = exports
