Joi = require "joi"

validateId = Joi.string().length(24)

module.exports =
  validateId: validateId

