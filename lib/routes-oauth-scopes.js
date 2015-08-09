(function() {
  var Boom, Hoek, Joi, _, apiPagination, helperObjToRestOauthScope, i18n, validationSchemas;

  _ = require('underscore');

  apiPagination = require('api-pagination');

  Boom = require('boom');

  Hoek = require('hoek');

  Joi = require('joi');

  helperObjToRestOauthScope = require('./helper-obj-to-rest-oauth-scope');

  i18n = require('./i18n');

  validationSchemas = require('./validation-schemas');

  module.exports = function(plugin, options) {
    var fnAccountId, fnIsInServerAdmin, fnOauthScopesBaseUrl, fnRaise404, hapiOauthStoreMultiTenant, methodsOauthScopes;
    if (options == null) {
      options = {};
    }
    Hoek.assert(options._tenantId, i18n.optionsAccountIdRequired);
    Hoek.assert(options.baseUrl, i18n.optionsBaseUrlRequired);
    Hoek.assert(options.routesScopesBaseName, i18n.optionsRoutesScopesBaseNameRequired);
    Hoek.assert(options.serverAdminScopeName, i18n.optionsServerAdminScopeNameRequired);
    hapiOauthStoreMultiTenant = function() {
      return plugin.plugins['hapi-oauth-store-multi-tenant'];
    };
    Hoek.assert(hapiOauthStoreMultiTenant(), i18n.couldNotFindPlugin);
    methodsOauthScopes = function() {
      return hapiOauthStoreMultiTenant().methods.oauthScopes;
    };
    Hoek.assert(methodsOauthScopes(), i18n.couldNotFindMethodsOauthScopes);
    fnRaise404 = function(request, reply) {
      return reply(Boom.notFound(i18n.notFoundPrefix + " " + options.baseUrl + request.path));
    };

    /*
    Returns the _tenantId to use.
     */
    fnAccountId = function(request, cb) {
      return cb(null, options._tenantId);
    };
    if (options._tenantId && _.isFunction(options._tenantId)) {
      fnAccountId = options.fnAccountId;
    }

    /*
    Determines if the current request is in serverAdmin scope
     */
    fnIsInServerAdmin = function(request) {
      var ref, ref1, scopes;
      scopes = ((ref = request.auth) != null ? (ref1 = ref.credentials) != null ? ref1.scopes : void 0 : void 0) || [];
      return _.contains(scopes, options.serverAdminScopeName);
    };

    /*
    Builds the base url for oauthScopes, defaults to ../oauthScopes
     */
    fnOauthScopesBaseUrl = function() {
      return options.baseUrl + "/" + options.routesScopesBaseName;
    };
    plugin.route({
      path: "/" + options.routesScopesBaseName,
      method: "GET",
      config: {
        validate: {
          params: validationSchemas.paramsOauthScopesGet
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, queryOptions;
          if (err) {
            return reply(err);
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          queryOptions = {};
          queryOptions.offset = apiPagination.parseInt(request.query.offset, 0);
          queryOptions.count = apiPagination.parseInt(request.query.count, 20);
          if (!isInServerAdmin) {
            queryOptions.where = {
              isInternal: false
            };
          }
          return methodsOauthScopes().all(_tenantId, queryOptions, function(err, oauthScopesResult) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnOauthScopesBaseUrl();
            oauthScopesResult.items = _.map(oauthScopesResult.items, function(x) {
              return helperObjToRestOauthScope(x, baseUrl, isInServerAdmin);
            });
            return reply(apiPagination.toRest(oauthScopesResult, baseUrl));
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesScopesBaseName,
      method: "POST",
      config: {
        validate: {
          payload: validationSchemas.payloadOauthScopesPost
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, ref;
          if (err) {
            return reply(err);
          }
          if (!((ref = request.auth) != null ? ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          if (!isInServerAdmin) {
            return reply(Boom.forbidden("'" + options.serverAdminScopeName + "' " + i18n.serverAdminScopeRequired));
          }
          return methodsOauthScopes().create(_tenantId, request.payload, null, function(err, oauthScope) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnOauthScopesBaseUrl();
            return reply(helperObjToRestOauthScope(oauthScope, baseUrl, isInServerAdmin)).code(201);
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesScopesBaseName + "/{oauthScopeId}",
      method: "DELETE",
      config: {
        validate: {
          params: validationSchemas.paramsOauthScopesDelete
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, ref;
          if (err) {
            return reply(err);
          }
          if (!((ref = request.auth) != null ? ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          if (!isInServerAdmin) {
            return reply(Boom.forbidden("'" + options.serverAdminScopeName + "' " + i18n.serverAdminScopeRequired));
          }
          return methodsOauthScopes().destroy(request.params.oauthScopeId, null, function(err, oauthScope) {
            if (err) {
              return reply(err);
            }
            return reply().code(204);
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesScopesBaseName + "/{oauthScopeId}",
      method: "PATCH",
      config: {
        validate: {
          params: validationSchemas.paramsOauthScopesPatch,
          payload: validationSchemas.payloadOauthScopesPatch
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, ref;
          if (err) {
            return reply(err);
          }
          if (!((ref = request.auth) != null ? ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          if (!isInServerAdmin) {
            return reply(Boom.forbidden("'" + options.serverAdminScopeName + "' " + i18n.serverAdminScopeRequired));
          }
          return methodsOauthScopes().get(request.params.oauthScopeId, null, function(err, oauthScope) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            if (!oauthScope) {
              return reply(Boom.notFound(request.url));
            }
            baseUrl = fnOauthScopesBaseUrl();
            return methodsOauthScopes().patch(request.params.oauthScopeId, request.payload, null, function(err, oauthScope) {
              if (err) {
                return reply(err);
              }
              return reply(helperObjToRestOauthScope(oauthScope, baseUrl, isInServerAdmin)).code(200);
            });
          });
        });
      }
    });
    return plugin.route({
      path: "/" + options.routesScopesBaseName + "/{oauthScopeId}",
      method: "GET",
      config: {
        validate: {
          params: validationSchemas.paramsOauthScopesGetOne
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, ref;
          if (err) {
            return reply(err);
          }
          if (!((ref = request.auth) != null ? ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          return methodsOauthScopes().get(request.params.oauthScopeId, null, function(err, oauthScope) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            if (!oauthScope) {
              return reply(Boom.notFound(request.url));
            }
            baseUrl = fnOauthScopesBaseUrl();
            return reply(helperObjToRestOauthScope(oauthScope, baseUrl, isInServerAdmin)).code(200);
          });
        });
      }
    });
  };

}).call(this);

//# sourceMappingURL=routes-oauth-scopes.js.map
