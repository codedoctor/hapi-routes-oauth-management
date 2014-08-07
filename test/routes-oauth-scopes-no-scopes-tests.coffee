assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'
shouldHttp = require './support/should-http'
shouldOauthScopes = require './support/should-oauth-scopes'

describe 'NO ROLES IN DB', ->
  server = null

  describe 'with server setup', ->
    beforeEach (cb) ->
      loadServer (err,serverResult) ->
        return cb err if err
        server = serverResult
        setupServer server,(err) ->
          cb err

    describe 'GET /oauth-scopes', ->
      describe 'with NO credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200PagedEmptyResult server,'/oauth-scopes',null, cb

      describe 'with USER credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200PagedEmptyResult server,'/oauth-scopes',fixtures.credentialsUser, cb

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200PagedEmptyResult server,'/oauth-scopes',fixtures.credentialsServerAdmin, cb


    describe 'POST /oauth-scopes', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.post server, '/oauth-scopes', fixtures.oauthScope1,null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.post server, '/oauth-scopes', fixtures.oauthScope1,fixtures.credentialsUser, 403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 201', (cb) ->
          shouldHttp.post server, '/oauth-scopes', fixtures.oauthScope1,fixtures.credentialsServerAdmin,201, (err,response) ->
            return cb err if err
            shouldOauthScopes.isValidServerAdminOauthScope response.result
            cb null


    describe 'DELETE /oauth-scopes/[wrongid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.delete server, "/oauth-scopes/#{fixtures.invalidOauthScopeId}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.delete server, "/oauth-scopes/#{fixtures.invalidOauthScopeId}",fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 204', (cb) ->
          shouldHttp.delete server,"/oauth-scopes/#{fixtures.invalidOauthScopeId}",fixtures.credentialsServerAdmin,204, (err,response) ->
            cb err

    describe 'PATCH /oauth-scopes/[wrongid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.patch server, "/oauth-scopes/#{fixtures.invalidOauthScopeId}",fixtures.oauthScope1,null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.patch server, "/oauth-scopes/#{fixtures.invalidOauthScopeId}",fixtures.oauthScope1,fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 404', (cb) ->
          shouldHttp.patch server,"/oauth-scopes/#{fixtures.invalidOauthScopeId}",fixtures.oauthScope1,fixtures.credentialsServerAdmin,404, (err,response) ->
            cb err


    describe 'GET /oauth-scopes/[wrongid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.get server, "/oauth-scopes/#{fixtures.invalidOauthScopeId}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 404', (cb) ->
          shouldHttp.get server, "/oauth-scopes/#{fixtures.invalidOauthScopeId}",fixtures.credentialsUser,404, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 404', (cb) ->
          shouldHttp.get server,"/oauth-scopes/#{fixtures.invalidOauthScopeId}",fixtures.credentialsServerAdmin,404, (err,response) ->
            cb err
    