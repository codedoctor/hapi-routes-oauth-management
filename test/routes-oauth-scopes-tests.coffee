assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'
setupOauthScopes = require './support/setup-oauth-scopes'
shouldHttp = require './support/should-http'

shouldOauthScopes = require './support/should-oauth-scopes'

describe 'oauthScopes in db', ->
  server = null

  describe 'with server setup and users', ->

    beforeEach (cb) ->
      loadServer (err,serverResult) ->
        return cb err if err
        server = serverResult
        setupServer server,(err) ->
          return cb err if err
          setupOauthScopes server,(err) ->
            cb err

    describe 'GET /oauth-scopes', ->
      describe 'with NO credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200Paged server,'/oauth-scopes',2,null, cb

      describe 'with USER credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200Paged server,'/oauth-scopes',2,fixtures.credentialsUser, (err,response) ->
            return cb err if err

            for item in response.result.items
              shouldOauthScopes.isValidUserOauthScope item

            cb null


      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200Paged server,'/oauth-scopes',3,fixtures.credentialsServerAdmin, (err,response) ->
            return cb err if err

            for item in response.result.items
               shouldOauthScopes.isValidServerAdminOauthScope item

            cb null

    describe 'DELETE /oauth-scopes/[validid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.delete server, "/oauth-scopes/#{fixtures.oauthScope1.id}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.delete server, "/oauth-scopes/#{fixtures.oauthScope1.id}",fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 204', (cb) ->
          shouldHttp.delete server,"/oauth-scopes/#{fixtures.oauthScope1.id}",fixtures.credentialsServerAdmin,204, (err,response) ->
            cb err

    describe 'PATCH /oauth-scopes/[validid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.patch server, "/oauth-scopes/#{fixtures.oauthScope1.id}",fixtures.oauthScope1,null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.patch server, "/oauth-scopes/#{fixtures.oauthScope1.id}",fixtures.oauthScope1,fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.patch server,"/oauth-scopes/#{fixtures.oauthScope1.id}",fixtures.oauthScope1,fixtures.credentialsServerAdmin,200, (err,response) ->
            return cb err if err
            shouldOauthScopes.isValidServerAdminOauthScope response.result
            cb null

    describe 'GET /oauth-scopes/[validid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.get server, "/oauth-scopes/#{fixtures.oauthScope1.id}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get server, "/oauth-scopes/#{fixtures.oauthScope1.id}",fixtures.credentialsUser,200, (err,response) ->
            return cb err if err
            shouldOauthScopes.isValidUserOauthScope response.result
            cb null

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get server,"/oauth-scopes/#{fixtures.oauthScope1.id}",fixtures.credentialsServerAdmin,200, (err,response) ->
            return cb err if err
            shouldOauthScopes.isValidServerAdminOauthScope response.result
            cb null

