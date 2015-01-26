
up = (migration, DataTypes, done) ->
  migration.createTable("<%=table%>",
    'id':
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
      type: DataTypes.INTEGER<% _.each(fields, function (field) { %>
    '<%= field.name %>':
      type: DataTypes.<%= field.type %>
      allowNull: <%= field.allownull %>
      unique: <%= field.unique %><% }); %>
    'active':
      type: DataTypes.BOOLEAN
      allowNull: false
      unique: false
      default: true
    'createdAt':
      allowNull: false,
      type: DataTypes.DATE
    'updatedAt':
      allowNull: false,
      type: DataTypes.DATE
    'deletedAt':
      allowNull: false,
      type: DataTypes.DATE
  ,
    engine: "<%= enginename %>"
  ).done(done)

down = (migration, DataTypes, done) ->
  migration.dropTable("<%=table%>").done(done)

exports = {
  up
  down
}

module.exports = exports
