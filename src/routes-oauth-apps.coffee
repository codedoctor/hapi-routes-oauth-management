_ = require 'underscore'
apiPagination = require 'api-pagination'
Boom = require 'boom'
Hoek = require "hoek"

helperObjToRest = require './helper-obj-to-rest'
i18n = require './i18n'
validationSchemas = require './validation-schemas'

module.exports = (plugin,options = {}) ->
  Hoek.assert options.accountId, i18n.optionsAccountIdRequired
  Hoek.assert options.baseUrl,i18n.optionsBaseUrlRequired
  Hoek.assert options.routesAppsBaseName,i18n.optionsRoutesAppsBaseNameRequired
  Hoek.assert options.serverAdminScopeName,i18n.optionsServerAdminScopeNameRequired

  hapiIdentityStore = -> plugin.plugins['hapi-identity-store']
  Hoek.assert hapiIdentityStore(),i18n.couldNotFindPlugin

  methodsOauthApps = -> hapiIdentityStore().methods.oauthApps
  Hoek.assert methodsOauthApps(),i18n.couldNotFindMethodsOauthApps

  fnRaise404 = (request,reply) ->
    reply Boom.notFound("#{i18n.notFoundPrefix} #{options.baseUrl}#{request.path}")

  ###
  Returns the accountId to use.
  ###
  fnAccountId = (request,cb) ->
    cb null, options.accountId

  fnAccountId = options.fnAccountId if options.accountId and _.isFunction(options.accountId)

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
      fnAccountId request, (err,accountId) ->
        return reply err if err

        isInServerAdmin = fnIsInServerAdmin(request)

        queryOptions = {}
        queryOptions.offset = apiPagination.parseInt(request.query.offset,0)
        queryOptions.count = apiPagination.parseInt(request.query.count,20)
        queryOptions.where = isInternal : false unless isInServerAdmin

        methodsOauthApps().all accountId, queryOptions,  (err,oauthAppsResult) ->
          return reply err if err

          baseUrl = fnOauthAppsBaseUrl()

          oauthAppsResult.items = _.map(oauthAppsResult.items, (x) -> helperObjToRest.oauthApp(x,baseUrl,isInServerAdmin) )   

          reply( apiPagination.toRest( oauthAppsResult,baseUrl))

  
  plugin.route
    path: "/#{options.routesAppsBaseName}"
    method: "POST"
    config:
      validate:
        payload: validationSchemas.payloadOauthAppsPost
    handler: (request, reply) ->
      fnAccountId request, (err,accountId) ->
        return reply err if err
        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        isInServerAdmin = fnIsInServerAdmin(request)
        return reply Boom.forbidden("'#{options.serverAdminScopeName}' #{i18n.serverAdminScopeRequired}") unless isInServerAdmin

        methodsOauthApps().create accountId, request.payload, null,  (err,oauthApp) ->
          return reply err if err

          baseUrl = fnOauthAppsBaseUrl()
          reply(helperObjToRest.oauthApp(oauthApp,baseUrl,isInServerAdmin)).code(201)


  plugin.route
    path: "/#{options.routesAppsBaseName}/{oauthAppId}"
    method: "DELETE"
    config:
      validate:
        params: validationSchemas.paramsOauthAppsDelete
    handler: (request, reply) ->
      console.log 'UUUUUUU'
      fnAccountId request, (err,accountId) ->
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
      fnAccountId request, (err,accountId) ->
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
            reply(helperObjToRest.oauthApp(oauthApp,baseUrl,isInServerAdmin)).code(200)

  plugin.route
    path: "/#{options.routesAppsBaseName}/{oauthAppId}"
    method: "GET"
    config:
      validate:
        params: validationSchemas.paramsOauthAppsGetOne
    handler: (request, reply) ->
      fnAccountId request, (err,accountId) ->
        return reply err if err

        return reply Boom.unauthorized(i18n.authorizationRequired) unless request.auth?.credentials
        
        isInServerAdmin = fnIsInServerAdmin(request)

        methodsOauthApps().get request.params.oauthAppId,  null,  (err,oauthApp) ->
          return reply err if err
          return reply Boom.notFound(request.url) unless oauthApp

          baseUrl = fnOauthAppsBaseUrl()
          reply(helperObjToRest.oauthApp(oauthApp,baseUrl,isInServerAdmin)).code(200)

