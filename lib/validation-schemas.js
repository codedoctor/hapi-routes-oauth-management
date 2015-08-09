(function() {
  var Joi, validateId;

  Joi = require("joi");

  validateId = Joi.string().length(24);

  module.exports = {
    validateId: validateId
  };

}).call(this);

//# sourceMappingURL=validation-schemas.js.map
