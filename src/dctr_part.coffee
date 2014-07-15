class DctrPart
  constructor: (@row, attrsBuilder = =>) ->
    @_attrs = {}
    attrsBuilder.apply(@)

  k: (keyIndex, keyName, converter = @titleCase) ->
    val = @row[keyIndex]
    @kv(keyName, val, converter)

  kv: (key, value, converter = @literal) ->
    unless @isEmpty(value)
      @_attrs[key] = converter.apply(@, [value])

  isEmpty: (val) ->
    !val? || val == '' || typeof(val) == 'number' && isNaN(val)

  literal: (v) -> v

  int: (v) -> parseInt(v)

  string: (v) -> (v? && v.toString()) || ""

  lowerCase: (v) -> @string(v).toLowerCase()

  capitalize: (v) ->
    return v if v == ""

    v = @string(v).toLowerCase()
    "#{v[0].toUpperCase()}#{v[1..-1]}"

  titleCase: (v) ->
    (@capitalize(word) for word in @string(v).split(" ")).join(" ")

  toDate: (v) ->
    epoch = Date.parse(v)

    if isNaN(epoch)
      null
    else
      date = new Date(v)
      "#{date.getFullYear()}-#{@pad(date.getMonth() + 1)}-#{@pad(date.getDate())}"

  toBoolean: (v) ->
    switch v
      when "y", "Y" then true
      when "n", "N" then false
      else null

  toEntityType: (v) ->
    switch @int(v)
      when 1 then "Individual"
      when 2 then "Organization"
      else null

  toIdentifierType: (v)->
    switch @int(v)
      when 1 then "Other"
      when 2 then "Medicare UPIN"
      when 4 then "Medicare ID"
      when 5 then "Medicaid"
      when 6 then "Medicare OSCAR/Certification"
      when 7 then "Medicare NSC"
      when 8 then "Medicare PIN"
      else null

  pad: (number, pad=2) ->
    n = Math.pow(10, pad)

    if number < n
      ("" + (n + number)).slice(1)
    else
      "" + number

module.exports = DctrPart
