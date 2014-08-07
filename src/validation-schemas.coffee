Joi = require "joi"

validateId = Joi.string().length(24)

module.exports =
  validateId: validateId

  paramsOauthScopesDelete: Joi.object().keys(
      oauthScopeId: validateId.required() 
    )

  paramsOauthScopesPatch: Joi.object().keys(
      oauthScopeId: validateId.required() 
    )

  paramsOauthScopesGet: Joi.object().keys()

  paramsOauthScopesGetOne: Joi.object().keys(
      oauthScopeId: validateId.required() 
    )

  payloadOauthScopesPatch: Joi.object().keys().options({ allowUnkown: true, stripUnknown: false }) 
  payloadOauthScopesPost: Joi.object().options({ allowUnkown: true, stripUnknown: false })

    ###
      accountId:
        type: mongoose.Schema.ObjectId
        require: true
      name:
        type : String
      description:
        type : String
        default: ''
      developerDescription:
        type : String
        default: ''
      roles:
        type: [String]
        default: -> []
    ###

  paramsOauthAppsDelete: Joi.object().keys(
      oauthAppId: validateId.required() 
    )

  paramsOauthAppsPatch: Joi.object().keys(
      oauthAppId: validateId.required() 
    )

  paramsOauthAppsGet: Joi.object().keys()

  paramsOauthAppsGetOne: Joi.object().keys(
      oauthAppId: validateId.required() 
    )

  payloadOauthAppsPatch: Joi.object().keys().options({ allowUnkown: true, stripUnknown: false }) 
  payloadOauthAppsPost: Joi.object().keys().options({ allowUnkown: true, stripUnknown: false })

