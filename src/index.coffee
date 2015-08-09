###
@author Martin Wawrusch (martin@wawrusch.com)
###

Hoek = require 'hoek'
i18n = require './i18n'

###
Main entry point for the plugin

@param [Plugin] plugin the HAPI plugin
@param [Object] options the plugin options
@option options [String|Function] _tenantId the account id to use, or an async function.
@option options [String] baseUrl the url to your API. For example https://api.mystuff.com
@option options [String] routesBaseName the name of the endpoints, defaults to role.
@option options [String] serverAdminScopeName the name of the serverAdmin scope, defaults to serverAdmin.
@param [Function] cb the callback invoked after completion

When passing a function to the _tenantId the signature needs to be as follows:

```coffeescript
  fnAccountId = (request,cb) ->
    _tenantId = null
    # lookup _tenantId here ...
    cb null, _tenantId

```
###

routesToExpose = [
  require './routes-oauth-apps-get'
  require './routes-oauth-apps-oauthappid-delete'
  require './routes-oauth-apps-oauthappid-get'
  require './routes-oauth-apps-oauthappid-patch'
  require './routes-oauth-apps-post'
  require './routes-oauth-scopes-get'
  require './routes-oauth-scopes-oauthscopeid-delete'
  require './routes-oauth-scopes-oauthscopeid-get'
  require './routes-oauth-scopes-oauthscopeid-patch'
  require './routes-oauth-scopes-post'
]


module.exports.register = (server, options = {}, cb) ->

  defaults =
    routesAppsBaseName: 'oauth-apps'
    routesScopesBaseName: 'oauth-scopes'
    serverAdminScopeName: 'server-admin'
    routeTagsPublic: ['api','api-public']
    routeTagsAdmin: ['api','api-admin']
  options = Hoek.applyToDefaults defaults, options

  r server,options for r in routesToExpose

  server.expose 'i18n',i18n

  cb()

###
@nodoc
###
module.exports.register.attributes =
  pkg: require '../package.json'

