
up = (sequelize, DataTypes, done) ->
  sequelize.changeColumn "<%=table%>", "<%=column%>", DataTypes.<%=dataType%>

  done()

down = (sequelize, DataTypes, done) ->
  done()

exports = {
  up
  down
}

module.exports = exports
