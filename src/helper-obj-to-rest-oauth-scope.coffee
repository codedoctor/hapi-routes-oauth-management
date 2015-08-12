_ = require 'underscore'

module.exports = (oauthScope,baseUrl,isInAdminScope) ->
    return null unless oauthScope

    res = 
      _url : "#{baseUrl}/#{oauthScope._id}"
      id : oauthScope._id
      _id : oauthScope._id
      name: oauthScope.name
      description: oauthScope.description

    if isInAdminScope
      res._tenantId = oauthScope._tenantId
      res.isInternal = oauthScope.isInternal

    res
