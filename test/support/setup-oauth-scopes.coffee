fixtures = require './fixtures'
async = require 'async'
module.exports = (server,cb) ->

  oauthScopes = [fixtures.oauthScope1,fixtures.oauthScope2,fixtures.oauthScopeInternal1]
  delete r.id for r in oauthScopes

  methods = server.pack.plugins['hapi-identity-store'].methods

  addOauthScope = (oauthScopeData,cb) ->
    methods.oauthScopes.create fixtures.accountId,oauthScopeData,null, (err,oauthScope) ->
      return cb err if err
      oauthScopeData.id = oauthScope._id
      cb null,oauthScope

  async.eachSeries oauthScopes ,addOauthScope, (err) ->
    cb err
