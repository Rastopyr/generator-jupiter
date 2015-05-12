
xlsx = require 'xlsx'

class XLSX
  constructor: (options) ->
    if @ not instanceof XLSX
      return new XLSX options

    @.options = options || {}

    return @

  parseFile: (file, type) ->
    type = type || 'binary'

    return xlsx.read file,
      type: type

  listOfSheets: (workbook) ->

exports =
  XLSX: XLSX

module.exports = exports
