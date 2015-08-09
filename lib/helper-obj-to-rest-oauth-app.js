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
      name: oauthApp.name,
      description: oauthApp.description
    };
    if (isInAdminScope) {
      res._tenantId = oauthApp._tenantId;
      res.isInternal = oauthApp.isInternal;
    }
    return res;
  };

}).call(this);

//# sourceMappingURL=helper-obj-to-rest-oauth-app.js.map
