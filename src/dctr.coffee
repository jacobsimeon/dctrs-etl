class Dctr
  constructor: (@row) ->

  meta: ->
    JSON.stringify @metaAttrs()

  json: ->
    JSON.stringify @attrs()

  metaAttrs: ->
    { create: { _index: "dctrs", _type: "dctr", _id: @npi() }}

  attrs: ->
    npi: @npi()

  npi: ->
    @npi ||= @row[0]

module.exports = Dctr
