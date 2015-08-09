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
    path: "/#{options.routesScopesBaseName}/{oauthScopeId}"
    method: "PATCH"
    config:
      tags: options.routeTagsAdmin
      validate:
        params: Joi.object().keys(
                        oauthScopeId: validationSchemas.validateId.required() 
                    )
        payload: Joi.object().keys().options({ allowUnknown: true, stripUnknown: false }) 
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsOauthScopes().get request.params.oauthScopeId,  null,  (err,oauthScope) ->
          return reply err if err
          return reply Boom.notFound(request.url) unless oauthScope

          baseUrl = fnOauthScopesBaseUrl()

          methodsOauthScopes().patch request.params.oauthScopeId, request.payload, null,  (err,oauthScope) ->
            return reply err if err          
            reply(helperObjToRestOauthScope(oauthScope,baseUrl,isInServerAdmin)).code(200)
