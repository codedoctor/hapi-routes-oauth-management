(function() {
  var _;

  _ = require('underscore');

  module.exports = function(oauthScope, baseUrl, isInAdminScope) {
    var res;
    if (!oauthScope) {
      return null;
    }
    res = {
      _url: baseUrl + "/" + oauthScope._id,
      id: oauthScope._id,
      _id: oauthScope._id,
      name: oauthScope.name,
      description: oauthScope.description,
      isInternal: oauthScope.isInternal,
      developerDescription: oauthScope.developerDescription
    };
    if (isInAdminScope) {
      res._tenantId = oauthScope._tenantId;
    }
    return res;
  };

}).call(this);

//# sourceMappingURL=helper-obj-to-rest-oauth-scope.js.map
