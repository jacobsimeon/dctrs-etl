Csv = require "csv"
Dctr = require "./dctr"

class TransformDctrs
  constructor: (@in, @out) ->

  transform: ->
    Csv()
      .from.stream(@in)
      .to.stream(@out)
      .transform (row, index, callback) ->
        process.nextTick ->
          dctr = new Dctr(row)
          callback(null, "#{dctr.meta()}\n#{dctr.json()}\n")

module.exports = TransformDctrs
