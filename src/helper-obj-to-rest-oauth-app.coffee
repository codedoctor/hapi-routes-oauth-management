_ = require 'underscore'

module.exports = (oauthApp,baseUrl,isInAdminScope) ->
    return null unless oauthApp

    res = 
      _url : "#{baseUrl}/#{oauthApp._id}"
      id : oauthApp._id
      _id : oauthApp._id
      name: oauthApp.name
      description: oauthApp.description

    if isInAdminScope
      res._tenantId = oauthApp._tenantId
      res.isInternal = oauthApp.isInternal

    res


