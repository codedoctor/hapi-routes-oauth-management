fixtures = require './fixtures'
async = require 'async'
module.exports = (server,cb) ->

  oauthApps = [fixtures.oauthApp1,fixtures.oauthApp2,fixtures.oauthAppInternal1]
  delete r.id for r in oauthApps

  methods = server.pack.plugins['hapi-oauth-store-multi-tenant'].methods

  addOauthApp = (oauthAppData,cb) ->
    methods.oauthApps.create fixtures._tenantId,oauthAppData,null, (err,oauthApp) ->
      return cb err if err
      oauthAppData.id = oauthApp._id
      cb null,oauthApp

  async.eachSeries oauthApps ,addOauthApp, (err) ->
    cb err
