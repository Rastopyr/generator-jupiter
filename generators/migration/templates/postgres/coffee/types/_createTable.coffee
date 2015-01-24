
up = (sequelize, DataTypes, done) ->
  sequelize.createTab;e "<%=table%>",
  <% _.each(fields, function (field) { %>
    '<%= field.name %>':
      type: Sequelize.<%= field.type %>
      allowNull: <%= field.allownull %>
      unique: <%= field.unique %><% }); %>
  ,
    engine: "<%= enginename %>"

  done()

down = (sequelize, DataTypes, done) ->
  sequelize.dropTable "<%=table%>"

exports = {
  up
  down
}

module.exports = exports
