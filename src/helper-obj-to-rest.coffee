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
      res.accountId = oauthScope.accountId
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
      res.accountId = oauthApp.accountId
      res.isInternal = oauthApp.isInternal

    res

