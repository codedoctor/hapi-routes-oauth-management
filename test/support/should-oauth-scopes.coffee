should = require 'should'

module.exports =
  isValidUserOauthScope: (oauthScope) ->
    oauthScope.should.have.property "_url"
    oauthScope.should.have.property "name"
    oauthScope.should.have.property "description"
    oauthScope.should.have.property "id"

    oauthScope.should.not.have.property "isInternal"
    oauthScope.should.not.have.property "_tenantId"

  isValidServerAdminOauthScope: (oauthScope) ->
    oauthScope.should.have.property "_url"
    oauthScope.should.have.property "name"
    oauthScope.should.have.property "description"
    oauthScope.should.have.property "id"

    oauthScope.should.have.property "isInternal"
    oauthScope.should.have.property "_tenantId"
