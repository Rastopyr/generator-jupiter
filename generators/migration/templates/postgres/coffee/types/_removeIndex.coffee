
up = (migration, DataTypes, done) ->
  migration.removeIndex "<%=table%>", [<% _.each(columns, function(column, kc) { %>"<%=column%>"<% if(kc !==  columns.length-1) { %>, <% } }) %>]

  done()

down = (migration, DataTypes, done) ->
  migration.addIndex "<%=table%>", [<% _.each(columns, function(column, kc) { %>"<%=column%>"<% if(kc !==  columns.length-1) { %>, <% } }) %>]

  done()

exports = {
  up
  down
}

module.exports = exports
