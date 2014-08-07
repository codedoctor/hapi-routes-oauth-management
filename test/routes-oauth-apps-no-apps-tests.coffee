assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'
shouldHttp = require './support/should-http'
shouldOauthApps = require './support/should-oauth-apps'

describe 'no apps in db', ->
  server = null

  describe 'with server setup', ->
    beforeEach (cb) ->
      loadServer (err,serverResult) ->
        return cb err if err
        server = serverResult

        cb err
        #setupServer server,(err) ->
        #  cb err

    describe 'GET /oauth-apps', ->
      describe 'with NO credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200PagedEmptyResult server,'/oauth-apps',null, cb

      describe 'with USER credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200PagedEmptyResult server,'/oauth-apps',fixtures.credentialsUser, cb

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200PagedEmptyResult server,'/oauth-apps',fixtures.credentialsServerAdmin, cb


    describe 'POST /oauth-apps', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.post server, '/oauth-apps', fixtures.oauthApp1,null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.post server, '/oauth-apps', fixtures.oauthApp1,fixtures.credentialsUser, 403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 201', (cb) ->
          shouldHttp.post server, '/oauth-apps', fixtures.oauthApp1,fixtures.credentialsServerAdmin,201, (err,response) ->
            return cb err if err
            shouldOauthApps.isValidServerAdminOauthApp response.result
            cb null


    describe 'DELETE /oauth-apps/[wrongid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.delete server, "/oauth-apps/#{fixtures.invalidOauthAppId}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.delete server, "/oauth-apps/#{fixtures.invalidOauthAppId}",fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 204', (cb) ->
          shouldHttp.delete server,"/oauth-apps/#{fixtures.invalidOauthAppId}",fixtures.credentialsServerAdmin,204, (err,response) ->
            cb err

    describe 'PATCH /oauth-apps/[wrongid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.patch server, "/oauth-apps/#{fixtures.invalidOauthAppId}",fixtures.oauthApp1,null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.patch server, "/oauth-apps/#{fixtures.invalidOauthAppId}",fixtures.oauthApp1,fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 404', (cb) ->
          shouldHttp.patch server,"/oauth-apps/#{fixtures.invalidOauthAppId}",fixtures.oauthApp1,fixtures.credentialsServerAdmin,404, (err,response) ->
            cb err


    describe 'GET /oauth-apps/[wrongid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.get server, "/oauth-apps/#{fixtures.invalidOauthAppId}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 404', (cb) ->
          shouldHttp.get server, "/oauth-apps/#{fixtures.invalidOauthAppId}",fixtures.credentialsUser,404, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 404', (cb) ->
          shouldHttp.get server,"/oauth-apps/#{fixtures.invalidOauthAppId}",fixtures.credentialsServerAdmin,404, (err,response) ->
            cb err
    