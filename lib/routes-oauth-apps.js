(function() {
  var Boom, Hoek, Joi, _, apiPagination, helperObjToRestOauthApp, i18n, validationSchemas;

  _ = require('underscore');

  apiPagination = require('api-pagination');

  Boom = require('boom');

  Hoek = require("hoek");

  Joi = require('joi');

  helperObjToRestOauthApp = require('./helper-obj-to-rest-oauth-app');

  i18n = require('./i18n');

  validationSchemas = require('./validation-schemas');

  module.exports = function(plugin, options) {
    var fnAccountId, fnIsInServerAdmin, fnOauthAppsBaseUrl, hapiOauthStoreMultiTenant, methodsOauthApps;
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
    Builds the base url for oauth apps, defaults to ../oauth-apps
     */
    fnOauthAppsBaseUrl = function() {
      return options.baseUrl + "/" + options.routesAppsBaseName;
    };
    plugin.route({
      path: "/" + options.routesAppsBaseName,
      method: "GET",
      config: {
        tags: options.routeTagsPublic,
        validate: {
          params: Joi.object().keys()
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
              return helperObjToRestOauthApp(x, baseUrl, isInServerAdmin);
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
        tags: options.routeTagsPublic,
        validate: {
          payload: Joi.object().keys().options({
            allowUnknown: true,
            stripUnknown: false
          })
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
          return methodsOauthApps().create(_tenantId, request.payload, null, function(err, oauthApp) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            baseUrl = fnOauthAppsBaseUrl();
            return reply(helperObjToRestOauthApp(oauthApp, baseUrl, isInServerAdmin)).code(201);
          });
        });
      }
    });
    plugin.route({
      path: "/" + options.routesAppsBaseName + "/{oauthAppId}",
      method: "DELETE",
      config: {
        tags: options.routeTagsPublic,
        validate: {
          params: Joi.object().keys({
            oauthAppId: validationSchemas.validateId.required()
          })
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
        tags: options.routeTagsPublic,
        validate: {
          params: Joi.object().keys({
            oauthAppId: validationSchemas.validateId.required()
          }),
          payload: Joi.object().keys().options({
            allowUnknown: true,
            stripUnknown: false
          })
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
              return reply(helperObjToRestOauthApp(oauthApp, baseUrl, isInServerAdmin)).code(200);
            });
          });
        });
      }
    });
    return plugin.route({
      path: "/" + options.routesAppsBaseName + "/{oauthAppId}",
      method: "GET",
      config: {
        tags: options.routeTagsPublic,
        validate: {
          params: Joi.object().keys({
            oauthAppId: validationSchemas.validateId.required()
          })
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
          return methodsOauthApps().get(request.params.oauthAppId, null, function(err, oauthApp) {
            var baseUrl;
            if (err) {
              return reply(err);
            }
            if (!oauthApp) {
              return reply(Boom.notFound(request.url));
            }
            baseUrl = fnOauthAppsBaseUrl();
            return reply(helperObjToRestOauthApp(oauthApp, baseUrl, isInServerAdmin)).code(200);
          });
        });
      }
    });
  };

}).call(this);

//# sourceMappingURL=routes-oauth-apps.js.map
