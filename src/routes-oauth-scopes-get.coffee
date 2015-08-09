_ = require 'underscore'
apiPagination = require 'api-pagination'
Boom = require 'boom'
Hoek = require 'hoek'
Joi = require 'joi'

helperObjToRestOauthScope = require './helper-obj-to-rest-oauth-scope'
i18n = require './i18n'
validationSchemas = require './validation-schemas'

module.exports = (plugin,options = {}) ->
  Hoek.assert options._tenantId, i18n.optionsAccountIdRequired
  Hoek.assert options.baseUrl,i18n.optionsBaseUrlRequired
  Hoek.assert options.routesScopesBaseName,i18n.optionsRoutesScopesBaseNameRequired
  Hoek.assert options.serverAdminScopeName,i18n.optionsServerAdminScopeNameRequired

  hapiOauthStoreMultiTenant = -> plugin.plugins['hapi-oauth-store-multi-tenant']
  Hoek.assert hapiOauthStoreMultiTenant(),i18n.couldNotFindPlugin

  methodsOauthScopes = -> hapiOauthStoreMultiTenant().methods.oauthScopes
  Hoek.assert methodsOauthScopes(),i18n.couldNotFindMethodsOauthScopes

  ###
  Returns the _tenantId to use.
  ###
  fnAccountId = (request,cb) ->
    cb null, options._tenantId

  fnAccountId = options.fnAccountId if options._tenantId and _.isFunction(options._tenantId)

  ###
  Determines if the current request is in serverAdmin scope
  ###
  fnIsInServerAdmin = (request) ->
    scopes = (request.auth?.credentials?.scopes) || []
    return _.contains scopes,options.serverAdminScopeName

  ###
  Builds the base url for oauthScopes, defaults to ../oauthScopes
  ###
  fnOauthScopesBaseUrl = ->
    "#{options.baseUrl}/#{options.routesScopesBaseName}"

  plugin.route
    path: "/#{options.routesScopesBaseName}"
    method: "GET"
    config:
      tags: options.routeTagsPublic
      validate:
        params: Joi.object().keys()
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        isInServerAdmin = fnIsInServerAdmin(request)

        queryOptions = {}
        queryOptions.offset = apiPagination.parseInt(request.query.offset,0)
        queryOptions.count = apiPagination.parseInt(request.query.count,20)
        queryOptions.where = isInternal : false unless isInServerAdmin

        methodsOauthScopes().all _tenantId, queryOptions,  (err,oauthScopesResult) ->
          return reply err if err

          baseUrl = fnOauthScopesBaseUrl()

          oauthScopesResult.items = _.map(oauthScopesResult.items, (x) -> helperObjToRestOauthScope(x,baseUrl,isInServerAdmin) )   

          reply( apiPagination.toRest( oauthScopesResult,baseUrl))

  