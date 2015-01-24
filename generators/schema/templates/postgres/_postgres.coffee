
Sequelize = require 'sequelize'

schema = <% _.each(fields, function(field) { %>
	'<%= field.name %>':
		type: Sequelize.<%= field.type %>
		allowNull: <%= field.allownull %>
		<% if(field.unique) { %>unique: <%= field.unique %><% } %><% }); %>

options =
	tableName: "<%= options.tableName %>"
	timestamps: <%= options.timestamps %>
	paranoid: <%= options.paranoid %>
	underscored: <%= options.underscored %>
	associations: <% _.each(assocs, function(assoc) { %>
		'<%= assoc.type %>':
			modelName: "<%= assoc.model %>"
			<% if(assoc.as) { %>as: <%= assoc.as %><% } %>
			<% if(assoc.foreignKey) { %>foreignKey: <%= assoc.foreignKey %><% } %>
			<% if(assoc.otherKey) { %>otherKey: <%= assoc.otherKey %><% } %>
			<% if(assoc.through) { %>through: <%= assoc.through %><% } %><% }); %>

name = "<%= name %>"

type = "Postgres"

module.exports = exports = exports {
	schema,
	name,
	options,
	type
}
