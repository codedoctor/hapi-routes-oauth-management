_ = require 'underscore'
apiPagination = require 'api-pagination'
Boom = require 'boom'
Hoek = require "hoek"
Joi = require 'joi'

helperObjToRestOauthApp = require './helper-obj-to-rest-oauth-app'
i18n = require './i18n'
validationSchemas = require './validation-schemas'



module.exports = (plugin,options = {}) ->
  Hoek.assert options._tenantId, i18n.optionsAccountIdRequired
  Hoek.assert options.baseUrl,i18n.optionsBaseUrlRequired
  Hoek.assert options.routesAppsBaseName,i18n.optionsRoutesAppsBaseNameRequired
  Hoek.assert options.serverAdminScopeName,i18n.optionsServerAdminScopeNameRequired

  hapiOauthStoreMultiTenant = -> plugin.plugins['hapi-oauth-store-multi-tenant']
  Hoek.assert hapiOauthStoreMultiTenant(),i18n.couldNotFindPlugin

  methodsOauthApps = -> hapiOauthStoreMultiTenant().methods.oauthApps
  Hoek.assert methodsOauthApps(),i18n.couldNotFindMethodsOauthApps


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
  Builds the base url for oauth apps, defaults to ../oauth-apps
  ###
  fnOauthAppsBaseUrl = ->
    "#{options.baseUrl}/#{options.routesAppsBaseName}"

  plugin.route
    path: "/#{options.routesAppsBaseName}/{oauthAppId}"
    method: "PATCH"
    config:
      tags: options.routeTagsPublic
      validate:
        params: Joi.object().keys(
                        oauthAppId: validationSchemas.validateId.required() 
                  )
        payload: Joi.object().keys().options({ allowUnknown: true, stripUnknown: false }) 
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsOauthApps().get request.params.oauthAppId,  null,  (err,oauthApp) ->
          return reply err if err
          return reply Boom.notFound(request.url) unless oauthApp

          baseUrl = fnOauthAppsBaseUrl()

          methodsOauthApps().patch request.params.oauthAppId, request.payload, null,  (err,oauthApp) ->
            return reply err if err          
            reply(helperObjToRestOauthApp(oauthApp,baseUrl,isInServerAdmin)).code(200)
