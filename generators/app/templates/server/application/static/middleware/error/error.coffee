
view = getLibrary 'view'

module.exports = (code) ->
  (err, req, res, next) ->
    view.failureJSON(err.message, code) req, res, next

