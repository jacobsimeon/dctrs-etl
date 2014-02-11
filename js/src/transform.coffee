csv = require "csv"


class @TransformDctrs
  constructor: (@in, @out) ->

  transform: ->
    csv()
      .from.stream(@in)
      .to.stream(@out)
      .transform (row, index, callback) ->
        process.nextTick ->
          dctr = new Dctr(row)
          callback(null, "#{dctr.meta()}\n#{dctr.json()}\n")

class Dctr
  constructor: (@csv) ->

  meta: ->
    JSON.stringify(@metaAttrs())

  json: ->
    JSON.stringify(@attrs())

  metaAttrs: ->
    { create: { _index: "dctrs", _type: "dctr", _id: @npi() }}
  attrs: ->
    { npi: @npi() }

  npi: ->
    @csv[0]
