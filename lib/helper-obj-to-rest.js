(function() {
  var _;

  _ = require('underscore');

  module.exports = {
    oauthScope: function(oauthScope, baseUrl, isInAdminScope) {
      var res;
      if (!oauthScope) {
        return null;
      }
      res = {
        _url: baseUrl + "/" + oauthScope._id,
        id: oauthScope._id,
        name: oauthScope.name,
        description: oauthScope.description
      };
      if (isInAdminScope) {
        res._tenantId = oauthScope._tenantId;
        res.isInternal = oauthScope.isInternal;
      }
      return res;
    },
    oauthApp: function(oauthApp, baseUrl, isInAdminScope) {
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
    }
  };

}).call(this);

//# sourceMappingURL=helper-obj-to-rest.js.map
