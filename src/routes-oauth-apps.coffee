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

  fnRaise404 = (request,reply) ->
    reply Boom.notFound("#{i18n.notFoundPrefix} #{options.baseUrl}#{request.path}")

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
    path: "/#{options.routesAppsBaseName}"
    method: "GET"
    config:
      validate:
        params: validationSchemas.paramsOauthAppsGet
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        isInServerAdmin = fnIsInServerAdmin(request)

        queryOptions = {}
        queryOptions.offset = apiPagination.parseInt(request.query.offset,0)
        queryOptions.count = apiPagination.parseInt(request.query.count,20)
        queryOptions.where = isInternal : false unless isInServerAdmin

        methodsOauthApps().all _tenantId, queryOptions,  (err,oauthAppsResult) ->
          return reply err if err

          baseUrl = fnOauthAppsBaseUrl()

          oauthAppsResult.items = _.map(oauthAppsResult.items, (x) -> helperObjToRestOauthApp(x,baseUrl,isInServerAdmin) )   

          reply( apiPagination.toRest( oauthAppsResult,baseUrl))

  
  plugin.route
    path: "/#{options.routesAppsBaseName}"
    method: "POST"
    config:
      validate:
        payload: validationSchemas.payloadOauthAppsPost
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err
        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsOauthApps().create _tenantId, request.payload, null,  (err,oauthApp) ->
          return reply err if err

          baseUrl = fnOauthAppsBaseUrl()
          reply(helperObjToRestOauthApp(oauthApp,baseUrl,isInServerAdmin)).code(201)


  plugin.route
    path: "/#{options.routesAppsBaseName}/{oauthAppId}"
    method: "DELETE"
    config:
      validate:
        params: validationSchemas.paramsOauthAppsDelete
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsOauthApps().destroy request.params.oauthAppId, null,  (err,oauthApp) ->
          return reply err if err
          
          reply().code(204)

  plugin.route
    path: "/#{options.routesAppsBaseName}/{oauthAppId}"
    method: "PATCH"
    config:
      validate:
        params: validationSchemas.paramsOauthAppsPatch
        payload: validationSchemas.payloadOauthAppsPatch
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

  plugin.route
    path: "/#{options.routesAppsBaseName}/{oauthAppId}"
    method: "GET"
    config:
      validate:
        params: validationSchemas.paramsOauthAppsGetOne
    handler: (request, reply) ->
      fnAccountId request, (err,_tenantId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        
        isInServerAdmin = fnIsInServerAdmin(request)

        methodsOauthApps().get request.params.oauthAppId,  null,  (err,oauthApp) ->
          return reply err if err
          return reply Boom.notFound(request.url) unless oauthApp

          baseUrl = fnOauthAppsBaseUrl()
          reply(helperObjToRestOauthApp(oauthApp,baseUrl,isInServerAdmin)).code(200)

