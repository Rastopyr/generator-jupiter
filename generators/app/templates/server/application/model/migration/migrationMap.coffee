
Sequelize = require 'sequelize'

schema = 
	'name':
		type: Sequelize.STRING
		allowNull: false
		unique: true
	'version':
		type: Sequelize.STRING
		allowNull: false
	'comment':
		type: Sequelize.STRING
		allowNull: true

options =
	tableName: "migrationMap"
	timestamps: true
	underscored: false

name = "migrationMap"

type = "Postgres"

module.exports = exports = {
	schema,
	name,
	options,
	type
}
