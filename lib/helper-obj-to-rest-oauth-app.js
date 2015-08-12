(function() {
  var _;

  _ = require('underscore');

  module.exports = function(oauthApp, baseUrl, isInAdminScope) {
    var res;
    if (!oauthApp) {
      return null;
    }
    res = {
      _url: baseUrl + "/" + oauthApp._id,
      id: oauthApp._id,
      _id: oauthApp._id,
      name: oauthApp.name,
      description: oauthApp.description,
      websiteUrl: oauthApp.websiteUrl,
      imageUrl: oauthApp.imageUrl,
      callbackUrl: oauthApp.callbackUrl,
      notes: oauthApp.notes,
      scopes: oauthApp.scopes,
      revoked: oauthApp.revoked,
      acceptTermsOfService: oauthApp.acceptTermsOfService,
      isPublished: oauthApp.isPublished,
      organizationName: oauthApp.organizationName,
      organizationUrl: oauthApp.organizationUrl,
      tosAcceptanceDate: oauthApp.tosAcceptanceDate,
      clients: oauthApp.clients,
      redirectUrls: oauthApp.redirectUrls,
      stats: oauthApp.stats,
      tags: oauthApp.tags,
      createdByUserId: oauthApp.createdByUserId,
      createdAt: oauthApp.createdAt,
      updatedAt: oauthApp.updatedAt
    };
    if (isInAdminScope) {
      res._tenantId = oauthApp._tenantId;
    }
    return res;
  };

}).call(this);

//# sourceMappingURL=helper-obj-to-rest-oauth-app.js.map
