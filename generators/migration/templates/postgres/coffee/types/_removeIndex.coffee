
up = (sequelize, DataTypes, done) ->
  sequelize.removeIndex "<%=table%>", [<% _.each(columns, function(column, kc) { %>"<%=column%>"<% if(kc !==  columns.length-1) { %>, <% } }) %>]

  done()

down = (sequelize, DataTypes, done) ->
  sequelize.addIndex "<%=table%>", [<% _.each(columns, function(column, kc) { %>"<%=column%>"<% if(kc !==  columns.length-1) { %>, <% } }) %>]

  done()

exports = {
  up
  down
}

module.exports = exports
