_ = require 'underscore'
fs = require 'fs'

fixtures = {}

_.each fs.readdirSync("./spec/fixtures"), (filename, index) ->
  jsonString = fs.readFileSync("./spec/fixtures/#{filename}")
  jsonObj = JSON.parse(jsonString)
  bareName = filename.replace(".json", "")

  fixtures[bareName] = jsonObj

module.exports = fixtures
