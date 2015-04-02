
Sequelize = require 'sequelize'

schema =
  'id':
    allowNull: false,
    autoIncrement: true,
    primaryKey: true,
    type: Sequelize.INTEGER<% _.each(fields, function(field) { %>
  '<%= field.name %>':
    type: Sequelize.<%= field.type %>
    allowNull: <%= field.allownull %>
    <% if(field.unique) { %>unique: <%= field.unique %><% } %><% }); %>

options =
  tableName: "<%= options.tableName %>"
  timestamps: <%= options.timestamps %>
  paranoid: <%= options.paranoid %>
  underscored: <%= options.underscored %>
  <% if(assocs.length) { %>associations: <% _.each(assocs, function(assoc) { %>
    '<%= assoc.type %>':
      modelName: "<%= assoc.model %>"
      <% if(assoc.as) { %>as: '<%= assoc.as %>'<% } %>
      <% if(assoc.foreignKey) { %>foreignKey: '<%= assoc.foreignKey %>'<% } %>
      <% if(assoc.otherKey) { %>otherKey: '<%= assoc.otherKey %>'<% } %>
      <% if(assoc.through) { %>through: '<%= assoc.through %>'<% } %><% }); %><% } %>

name = "<%= name %>"

type = "Postgres"

module.exports = exports = {
  schema
  name
  options
  type
}
