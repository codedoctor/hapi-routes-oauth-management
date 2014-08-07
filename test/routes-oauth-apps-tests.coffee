assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'
setupOauthApps = require './support/setup-oauth-apps'
shouldHttp = require './support/should-http'

shouldOauthApps = require './support/should-oauth-apps'

describe 'oauthApps in db', ->
  server = null

  describe 'with server setup and users', ->

    beforeEach (cb) ->
      loadServer (err,serverResult) ->
        return cb err if err
        server = serverResult
        setupServer server,(err) ->
          return cb err if err
          setupOauthApps server,(err) ->
            cb err

    describe 'GET /oauth-apps', ->
      describe 'with NO credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200Paged server,'/oauth-apps',2,null, cb

      describe 'with USER credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200Paged server,'/oauth-apps',2,fixtures.credentialsUser, (err,response) ->
            return cb err if err

            for item in response.result.items
              shouldOauthApps.isValidUserOauthApp item

            cb null


      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200Paged server,'/oauth-apps',3,fixtures.credentialsServerAdmin, (err,response) ->
            return cb err if err

            for item in response.result.items
               shouldOauthApps.isValidServerAdminOauthApp item

            cb null

    describe 'DELETE /oauth-apps/[validid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.delete server, "/oauth-apps/#{fixtures.oauthApp1.id}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.delete server, "/oauth-apps/#{fixtures.oauthApp1.id}",fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 204', (cb) ->
          shouldHttp.delete server,"/oauth-apps/#{fixtures.oauthApp1.id}",fixtures.credentialsServerAdmin,204, (err,response) ->
            cb err

    describe 'PATCH /oauth-apps/[validid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.patch server, "/oauth-apps/#{fixtures.oauthApp1.id}",fixtures.oauthApp1,null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.patch server, "/oauth-apps/#{fixtures.oauthApp1.id}",fixtures.oauthApp1,fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.patch server,"/oauth-apps/#{fixtures.oauthApp1.id}",fixtures.oauthApp1,fixtures.credentialsServerAdmin,200, (err,response) ->
            return cb err if err
            shouldOauthApps.isValidServerAdminOauthApp response.result
            cb null

    describe 'GET /oauth-apps/[validid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.get server, "/oauth-apps/#{fixtures.oauthApp1.id}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get server, "/oauth-apps/#{fixtures.oauthApp1.id}",fixtures.credentialsUser,200, (err,response) ->
            return cb err if err
            shouldOauthApps.isValidUserOauthApp response.result
            cb null

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get server,"/oauth-apps/#{fixtures.oauthApp1.id}",fixtures.credentialsServerAdmin,200, (err,response) ->
            return cb err if err
            shouldOauthApps.isValidServerAdminOauthApp response.result
            cb null

