should = require 'should'

module.exports =
  isValidUserOauthApp: (oauthApp) ->
    oauthApp.should.have.property "_url"
    oauthApp.should.have.property "name"
    oauthApp.should.have.property "description"
    oauthApp.should.have.property "id"

    oauthApp.should.not.have.property "isInternal"
    oauthApp.should.not.have.property "_tenantId"

  isValidServerAdminOauthApp: (oauthApp) ->
    oauthApp.should.have.property "_url"
    oauthApp.should.have.property "name"
    oauthApp.should.have.property "description"
    oauthApp.should.have.property "id"

    oauthApp.should.have.property "isInternal"
    oauthApp.should.have.property "_tenantId"
