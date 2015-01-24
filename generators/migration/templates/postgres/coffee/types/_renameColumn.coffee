
up = (sequelize, DataTypes, done) ->
  sequelize.renameColumn "<%=table%>", "<%=attrNameBefore%>", "<%=attrNameAfter%>"
  done()

down = (sequelize, DataTypes, done) ->
  sequelize.renameColumn "<%=table%>", "<%=attrNameAfter%>", "<%=attrNameBefore%>"
  done()

exports = {
  up
  down
}

module.exports = exports
