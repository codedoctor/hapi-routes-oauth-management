_ = require 'underscore'

module.exports =

  oauthScope: (oauthScope,baseUrl,isInAdminScope) ->
    return null unless oauthScope

    res = 
      _url : "#{baseUrl}/#{oauthScope._id}"
      id : oauthScope._id
      name: oauthScope.name
      description: oauthScope.description

    if isInAdminScope
      res._tenantId = oauthScope._tenantId
      res.isInternal = oauthScope.isInternal

    res

  oauthApp: (oauthApp,baseUrl,isInAdminScope) ->
    return null unless oauthApp

    res = 
      _url : "#{baseUrl}/#{oauthApp._id}"
      id : oauthApp._id
      name: oauthApp.name
      description: oauthApp.description

    if isInAdminScope
      res._tenantId = oauthApp._tenantId
      res.isInternal = oauthApp.isInternal

    res


