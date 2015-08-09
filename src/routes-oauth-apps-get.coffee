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
    path: "/#{options.routesAppsBaseName}"
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

        methodsOauthApps().all _tenantId, queryOptions,  (err,oauthAppsResult) ->
          return reply err if err

          baseUrl = fnOauthAppsBaseUrl()

          oauthAppsResult.items = _.map(oauthAppsResult.items, (x) -> helperObjToRestOauthApp(x,baseUrl,isInServerAdmin) )   

          reply( apiPagination.toRest( oauthAppsResult,baseUrl))

  