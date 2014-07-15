Dctr = require '../src/dctr'
fixtures = require './fixtures'

describe "Setting the provider's basic information", ->
  basicProvider = null
  beforeEach -> basicProvider = new Dctr(fixtures.provider_basic)

  it "Sets the NPI and meta data", ->
    attrs = basicProvider.attrs()

    expect(attrs.npi).toEqual("1730187477")
    expect(attrs.enumerated_on).toEqual("2005-07-07")
    expect(attrs.updated_on).toEqual("2012-08-27")

  it "Sets the mailng address", ->
    address = basicProvider.attrs().mailing_address

    expect(address.street).toEqual("900 Mohawk St")
    expect(address.street_second_line).toEqual("Suite A")
    expect(address.city).toEqual("Savannah")
    expect(address.state).toEqual("GA")
    expect(address.postal_code).toEqual("314191780")
    expect(address.phone).toEqual("9129202090")
    expect(address.fax).toEqual("9129204114")
    expect(address.country_code).toEqual("US")

  it "Sets the practice address", ->
    address = basicProvider.attrs().practice_address

    expect(address.street).toEqual("900 Mohawk St")
    expect(address.street_second_line).toEqual("Suite A")
    expect(address.city).toEqual("Savannah")
    expect(address.state).toEqual("GA")
    expect(address.postal_code).toEqual("314191780")
    expect(address.phone).toEqual("9129202090")
    expect(address.fax).toEqual("9129204114")
    expect(address.country_code).toEqual("US")

describe "Setting information for an individual provider", ->
  individualProvider = null
  beforeEach -> individualProvider = new Dctr(fixtures.provider_individual)

  it "Sets the provider type code", ->
    attrs = individualProvider.attrs()

    expect(attrs.entity_type).toEqual("Individual")

  it "Sets all the parts of the provider's name", ->
    attrs = individualProvider.attrs()

    expect(attrs.last_name).toEqual("Curtsinger")
    expect(attrs.first_name).toEqual("Luke")
    expect(attrs.middle_name).toEqual("J")
    expect(attrs.prefix).toEqual("Dr.")
    expect(attrs.suffix).toEqual("Jr.")
    expect(attrs.credential).toEqual("MD")
    expect(attrs.organization_name).toBeUndefined()
    expect(attrs.gender).toEqual("M")

describe "Setting information for an org provider", ->
  orgProvider = null
  beforeEach -> orgProvider = new Dctr(fixtures.provider_org)

  it "Sets the provider type code", ->
    attrs = orgProvider.attrs()
    expect(attrs.entity_type).toEqual("Organization")

  it "Sets the organization's name", ->
    attrs = orgProvider.attrs()

    orgName = "Cumberland County Hospital System, Inc"
    expect(attrs.organization_name).toEqual(orgName)

  it "Sets the information for the authorized official", ->
    attrs = orgProvider.attrs().authorized_official
    expect(attrs.first_name).toEqual("Michael")
    expect(attrs.last_name).toEqual("Nagowski")
    expect(attrs.middle_name).toEqual("J")
    expect(attrs.title).toEqual("CEO")
    expect(attrs.phone).toEqual("9106096700")

  it "Sets organization subpart flag", ->
    attrs = orgProvider.attrs()
    expect(attrs.subpart).toEqual(false)

describe "Setting 'other org' information", ->

  describe "when other org is an org provider", ->
    it "sets other org name", ->
      otherOrgOrg = new Dctr(fixtures.other_org_org)
      attrs = otherOrgOrg.attrs().other_org

      expect(attrs.name).toEqual "Cape Fear Valley Home Health And Hospice"

  describe "When other org is an individual provider", ->
    it "sets individual info", ->
      otherOrgIndividual = new Dctr(fixtures.other_org_individual)
      attrs = otherOrgIndividual.attrs().other_org

      expect(attrs.first_name).toEqual("Debbie")
      expect(attrs.last_name).toEqual("Mudder")
      expect(attrs.middle_name).toEqual("C")

describe "Setting deactiviation date", ->
  deactivatedProvider = null
  beforeEach -> deactivatedProvider = new Dctr(fixtures.provider_deactivated)

  it "Sets the deactivation date", ->
    attrs = deactivatedProvider.attrs()
    expect(attrs.deactivated_on).toEqual("2005-05-23")
    expect(attrs.reactivated_on).toEqual("2005-05-24")

describe "Building the collection of specialties", ->
  allSpecialties = null
  someSpecialties = null
  beforeEach ->
    allSpecialties = new Dctr(fixtures.multiple_specialties)
    someSpecialties = new Dctr(fixtures.provider_basic)

  it "creates a specialty for each item in the list", ->
    attrs = allSpecialties.attrs()
    collection = attrs.specialties
    expect(collection.length).toEqual(15)
    expect(collection[0]).toEqual
      taxonomy_code: '207KA0200X'
      license_number: '35061979G'
      state: 'OH'
      primary: false
      type: "Allopathic & Osteopathic Physicians"
      classification: "Allergy & Immunology"
      specialization: "Allergy"

  it "does not create empty specialties", ->
    collection = someSpecialties.attrs().specialties
    expect(collection.length).toEqual(1)
    expect(collection[0]).toEqual
      taxonomy_code: '174400000X'
      license_number: '45759'
      state: 'GA'
      primary: true
      type: "Other Service Providers"
      classification: "Specialist"
      specialization: undefined

describe "Building the collection of other identifiers", ->
  it "Builds an other identifier", ->
    otherIdentifiers = new Dctr(fixtures.other_identifier)
    attrs = otherIdentifiers.attrs()
    collection = attrs.other_identifiers

    expect(collection.length).toEqual(6)
    expect(collection[1]).toEqual
      identifier: '645540'
      type: "Other"
      state: 'KS'
      issuer: 'FIRSTGUARD'

  it "Correctly transforms the identifier type", ->
    otherIdType = new Dctr(fixtures.other_identifier_type)
    attrs = otherIdType.attrs().other_identifiers[0]
    console.log(attrs)
    expect(attrs.type).toEqual("Medicare UPIN")

describe "Setting the sole proprieter flag", ->
  it "Sets the flag", ->
    proprieter = new Dctr(fixtures.provider_proprieter)
    attrs = proprieter.attrs()
    expect(attrs.sole_proprietor).toEqual(null)

describe "Setting the parent org LBN", ->
  it "Sets the LBN", ->
    lbn = new Dctr(fixtures.parent_org_lbn)
    attrs = lbn.attrs()

    expect(attrs.parent_org_lbn).toEqual("NOVAMED, INC.")
