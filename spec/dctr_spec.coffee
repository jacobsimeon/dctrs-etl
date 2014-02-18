Dctr = require '../src/dctr'



describe "Parsing a Dctr", ->
  it "sets the npi number", ->
    dctr = new Dctr(["hello"])
    expect(dctr.npi()).toEqual("hello")
