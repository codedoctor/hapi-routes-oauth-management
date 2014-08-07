(function() {
  var Boom, Hoek, apiPagination, helperObjToRest, i18n, validationSchemas, _;

  _ = require('underscore');

  apiPagination = require('api-pagination');

  Boom = require('boom');

  Hoek = require("hoek");

  helperObjToRest = require('./helper-obj-to-rest');

  i18n = require('./i18n');

  validationSchemas = require('./validation-schemas');

  module.exports = function(plugin, options) {
    var fnAccountId, fnIsInServerAdmin, fnOauthScopesBaseUrl, fnRaise404, hapiIdentityStore, methodsOauthScopes;
    if (options == null) {
      options = {};
    }
    Hoek.assert(options.accountId, i18n.optionsAccountIdRequired);
    Hoek.assert(options.baseUrl, i18n.optionsBaseUrlRequired);
    Hoek.assert(options.routesScopesBaseName, i18n.optionsRoutesScopesBaseNameRequired);
    Hoek.assert(options.serverAdminScopeName, i18n.optionsServerAdminScopeNameRequired);
    hapiIdentityStore = function() {
      return plugin.plugins['hapi-identity-store'];
    };
    Hoek.assert(hapiIdentityStore(), i18n.couldNotFindPlugin);
    methodsOauthScopes = function() {
      return hapiIdentityStore().methods.oauthScopes;
    };
    Hoek.assert(methodsOauthScopes(), i18n.couldNotFindMethodsOauthScopes);
    fnRaise404 = function(request, reply) {
      return reply(Boom.notFound("" + i18n.notFoundPrefix + " " + options.baseUrl + request.path));
    };

    /*
    Returns the accountId to use.
     */
    fnAccountId = function(request, cb) {
      return cb(null, options.accountId);
    };
    if (options.accountId && _.isFunction(options.accountId)) {
      fnAccountId = options.fnAccountId;
    }

    /*
    Determines if the current request is in serverAdmin scope
     */
    fnIsInServerAdmin = function(request) {
      var scopes, _ref, _ref1;
      scopes = ((_ref = request.auth) != null ? (_ref1 = _ref.credentials) != null ? _ref1.scopes : void 0 : void 0) || [];
      return _.contains(scopes, options.serverAdminScopeName);
    };

    /*
    Builds the base url for oauthScopes, defaults to ../oauthScopes
     */
    fnOauthScopesBaseUrl = function() {
      return "" + options.baseUrl + "/" + options.routesScopesBaseName;
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
        return fnAccountId(request, function(err, accountId) {
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
          return methodsOauthScopes().all(accountId, queryOptions, function(err, oauthScopesResult) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnOauthScopesBaseUrl();
            oauthScopesResult.items = _.map(oauthScopesResult.items, function(x) {
              return helperObjToRest.oauthScope(x, baseUrl, isInServerAdmin);
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
        return fnAccountId(request, function(err, accountId) {
          var isInServerAdmin, _ref;
          if (err) {
            return reply(err);
          }
          if (!((_ref = request.auth) != null ? _ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          if (!isInServerAdmin) {
            return reply(Boom.forbidden("'" + options.serverAdminScopeName + "' " + i18n.serverAdminScopeRequired));
          }
          return methodsOauthScopes().create(accountId, request.payload, null, function(err, oauthScope) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnOauthScopesBaseUrl();
            return reply(helperObjToRest.oauthScope(oauthScope, baseUrl, isInServerAdmin)).code(201);
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
        return fnAccountId(request, function(err, accountId) {
          var isInServerAdmin, _ref;
          if (err) {
            return reply(err);
          }
          if (!((_ref = request.auth) != null ? _ref.credentials : void 0)) {
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
        return fnAccountId(request, function(err, accountId) {
          var isInServerAdmin, _ref;
          if (err) {
            return reply(err);
          }
          if (!((_ref = request.auth) != null ? _ref.credentials : void 0)) {
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
              return reply(helperObjToRest.oauthScope(oauthScope, baseUrl, isInServerAdmin)).code(200);
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
        return fnAccountId(request, function(err, accountId) {
          var isInServerAdmin, _ref;
          if (err) {
            return reply(err);
          }
          if (!((_ref = request.auth) != null ? _ref.credentials : void 0)) {
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
            return reply(helperObjToRest.oauthScope(oauthScope, baseUrl, isInServerAdmin)).code(200);
          });
        });
      }
    });
  };

}).call(this);

//# sourceMappingURL=routes-oauth-scopes.js.map
