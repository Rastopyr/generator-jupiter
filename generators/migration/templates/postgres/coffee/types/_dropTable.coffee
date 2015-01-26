
up = (migration, DataTypes, done) ->
  migration.dropTable "<%=table%>"

  done()

down = (migration, DataTypes, done) ->
  done()

exports = {
  up
  down
}

module.exports = exports
