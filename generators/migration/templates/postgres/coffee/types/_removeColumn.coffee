
up = (sequelize, DataTypes, done) ->
  sequelize.removeColumn "<%=table%>", "<%=column%>"

  done()

down = (sequelize, DataTypes, done) ->
  sequelize.addColumn "<%=table%>", "<%=column%>", DataTypes.<%=dataType%>

  done()

exports = {
  up
  down
}

module.exports = exports
