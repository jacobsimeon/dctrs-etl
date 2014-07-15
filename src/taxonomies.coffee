taxonomies = require './../data/taxonomies.json'

class Taxonomies
  constructor: (@_taxonomies) ->

  transform: (raw_taxonomy) ->
    @taxonomy = @findTaxonomy(raw_taxonomy.taxonomy_code)

    raw_taxonomy.type = @taxonomy["type"]
    raw_taxonomy.classification = @taxonomy["classification"]
    raw_taxonomy.specialization = @taxonomy["specialization"]

    raw_taxonomy

  findTaxonomy: (code) ->
    @_taxonomies[code] || {}

module.exports = new Taxonomies(taxonomies)
