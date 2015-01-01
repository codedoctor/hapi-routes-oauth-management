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
    var fnAccountId, fnIsInServerAdmin, fnOauthAppsBaseUrl, fnRaise404, hapiOauthStoreMultiTenant, methodsOauthApps;
    if (options == null) {
      options = {};
    }
    Hoek.assert(options._tenantId, i18n.optionsAccountIdRequired);
    Hoek.assert(options.baseUrl, i18n.optionsBaseUrlRequired);
    Hoek.assert(options.routesAppsBaseName, i18n.optionsRoutesAppsBaseNameRequired);
    Hoek.assert(options.serverAdminScopeName, i18n.optionsServerAdminScopeNameRequired);
    hapiOauthStoreMultiTenant = function() {
      return plugin.plugins['hapi-oauth-store-multi-tenant'];
    };
    Hoek.assert(hapiOauthStoreMultiTenant(), i18n.couldNotFindPlugin);
    methodsOauthApps = function() {
      return hapiOauthStoreMultiTenant().methods.oauthApps;
    };
    Hoek.assert(methodsOauthApps(), i18n.couldNotFindMethodsOauthApps);
    fnRaise404 = function(request, reply) {
      return reply(Boom.notFound("" + i18n.notFoundPrefix + " " + options.baseUrl + request.path));
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
      var scopes, _ref, _ref1;
      scopes = ((_ref = request.auth) != null ? (_ref1 = _ref.credentials) != null ? _ref1.scopes : void 0 : void 0) || [];
      return _.contains(scopes, options.serverAdminScopeName);
    };

    /*
    Builds the base url for oauth apps, defaults to ../oauth-apps
     */
    fnOauthAppsBaseUrl = function() {
      return "" + options.baseUrl + "/" + options.routesAppsBaseName;
    };
    plugin.route({
      path: "/" + options.routesAppsBaseName,
      method: "GET",
      config: {
        validate: {
          params: validationSchemas.paramsOauthAppsGet
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
          return methodsOauthApps().all(_tenantId, queryOptions, function(err, oauthAppsResult) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnOauthAppsBaseUrl();
            oauthAppsResult.items = _.map(oauthAppsResult.items, function(x) {
              return helperObjToRest.oauthApp(x, baseUrl, isInServerAdmin);
            });
            return reply(apiPagination.toRest(oauthAppsResult, baseUrl));
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesAppsBaseName,
      method: "POST",
      config: {
        validate: {
          payload: validationSchemas.payloadOauthAppsPost
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
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
          return methodsOauthApps().create(_tenantId, request.payload, null, function(err, oauthApp) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnOauthAppsBaseUrl();
            return reply(helperObjToRest.oauthApp(oauthApp, baseUrl, isInServerAdmin)).code(201);
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesAppsBaseName + "/{oauthAppId}",
      method: "DELETE",
      config: {
        validate: {
          params: validationSchemas.paramsOauthAppsDelete
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
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
          return methodsOauthApps().destroy(request.params.oauthAppId, null, function(err, oauthApp) {
            if (err) {
              return reply(err);
            }
            return reply().code(204);
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesAppsBaseName + "/{oauthAppId}",
      method: "PATCH",
      config: {
        validate: {
          params: validationSchemas.paramsOauthAppsPatch,
          payload: validationSchemas.payloadOauthAppsPatch
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
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
          return methodsOauthApps().get(request.params.oauthAppId, null, function(err, oauthApp) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            if (!oauthApp) {
              return reply(Boom.notFound(request.url));
            }
            baseUrl = fnOauthAppsBaseUrl();
            return methodsOauthApps().patch(request.params.oauthAppId, request.payload, null, function(err, oauthApp) {
              if (err) {
                return reply(err);
              }
              return reply(helperObjToRest.oauthApp(oauthApp, baseUrl, isInServerAdmin)).code(200);
            });
          });
        });
      }
    });
    return plugin.route({
      path: "/" + options.routesAppsBaseName + "/{oauthAppId}",
      method: "GET",
      config: {
        validate: {
          params: validationSchemas.paramsOauthAppsGetOne
        }
      },
      handler: function(request, reply) {
        return fnAccountId(request, function(err, _tenantId) {
          var isInServerAdmin, _ref;
          if (err) {
            return reply(err);
          }
          if (!((_ref = request.auth) != null ? _ref.credentials : void 0)) {
            return reply(Boom.unauthorized(i18n.authorizationRequired));
          }
          isInServerAdmin = fnIsInServerAdmin(request);
          return methodsOauthApps().get(request.params.oauthAppId, null, function(err, oauthApp) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            if (!oauthApp) {
              return reply(Boom.notFound(request.url));
            }
            baseUrl = fnOauthAppsBaseUrl();
            return reply(helperObjToRest.oauthApp(oauthApp, baseUrl, isInServerAdmin)).code(200);
          });
        });
      }
    });
  };

}).call(this);

//# sourceMappingURL=routes-oauth-apps.js.map
