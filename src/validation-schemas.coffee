Joi = require "joi"

validateId = Joi.string().length(24)

module.exports =
  validateId: validateId


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

  payloadOauthAppsPatch: Joi.object().keys().options({ allowUnknown: true, stripUnknown: false }) 
  payloadOauthAppsPost: Joi.object().keys().options({ allowUnknown: true, stripUnknown: false })

