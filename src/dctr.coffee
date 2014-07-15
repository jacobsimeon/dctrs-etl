_ = require "underscore"
DctrPart = require "./dctr_part"
Taxonomies = require './taxonomies'

class Dctr extends DctrPart
  constructor: (@row) -> @buildAttrs()

  meta: -> JSON.stringify @metaAttrs()

  json: -> JSON.stringify @attrs()

  attrs: -> @_attrs

  metaAttrs: ->
    { create: { _index: "dctrs", _type: "provider", _id: @row[0] }}

  buildAttrs: ->
    root = @part ->
      @k 0, "npi", @literal
      @k 1, "entity_type", @toEntityType

      # Organizations
      @k 4, "organization_name"

      # Individuals
      @k 5, "last_name"
      @k 6, "first_name"
      @k 7, "middle_name"
      @k 8, "prefix"
      @k 9, "suffix"
      @k 10, "credential", @literal
      @k 41, "gender", @literal

      # Basic Metadata
      @k 36, "enumerated_on", @toDate
      @k 37, "updated_on", @toDate
      @k 39, "deactivated_on", @toDate
      @k 40, "reactivated_on", @toDate
      @k 307, "sole_proprietor", @toBoolean
      @k 308, "subpart", @toBoolean
      @k 309, "parent_org_lbn", @literal

    root.other_org = @part ->
      @k 11, "name"
      @k 13, "last_name"
      @k 14, "first_name"
      @k 15, "middle_name", @literal
      @k 16, "prefix"
      @k 17, "suffix"
      @k 18, "credential", @literal

    root.mailing_address = @part ->
      @k 20, "street"
      @k 21, "street_second_line"
      @k 22, "city"
      @k 23, "state", @literal
      @k 24, "postal_code", @literal
      @k 25, "country_code", @literal
      @k 26, "phone", @literal
      @k 27, "fax", @literal

    root.practice_address = @part ->
      @k 28, "street"
      @k 29, "street_second_line"
      @k 30, "city"
      @k 31, "state", @literal
      @k 32, "postal_code", @literal
      @k 33, "country_code", @literal
      @k 34, "phone", @literal
      @k 35, "fax", @literal

    root.authorized_official = @part ->
      @k 42, "last_name"
      @k 43, "first_name"
      @k 44, "middle_name"
      @k 45, "title", @literal
      @k 46, "phone", @string
      @k 311, "prefix"
      @k 312, "suffix"
      @k 313, "credential", @literal

    root.specialties = @buildSpecialties()
    root.other_identifiers = @buildIdentifiers()

    @_attrs = root

  buildSpecialties: ->
    rawSpecialties = @partition [47..106], 4, (group) ->
      @k group[0], "taxonomy_code", @literal
      @k group[1], "license_number", @literal
      @k group[2], "state", @literal
      @k group[3], "primary", @toBoolean

      # expand description of specialty
      specialty = Taxonomies.findTaxonomy(@_attrs.taxonomy_code)
      @kv "type", specialty["type"]
      @kv "classification", specialty["classification"]
      @kv "specialization", specialty["specialization"]

  buildIdentifiers: ->
    @partition [107..306], 4, (group) ->
      @k group[0], "identifier", @string
      @k group[1], "type", @toIdentifierType
      @k group[2], "state", @literal
      @k group[3], "issuer", @literal

  part: (spec) ->
    new DctrPart(@row, spec)._attrs

  partition: (range, partitionSize, transform) ->
    groups = ([i..(i + partitionSize)] for i in range by partitionSize)
    _.compact((@transformGroup(group, transform) for group in groups))

  transformGroup: (group, transform) ->
    item = @part -> transform.apply(@, [group])
    item if item? && _.keys(item).length > 0

module.exports = Dctr
