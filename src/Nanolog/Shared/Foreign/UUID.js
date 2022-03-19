const { v4: uuidv4, validate } = require('uuid');

exports._validate = function (s) {
  return validate(s);
}

exports._genUUID = function () {
  return _ => uuidv4()
}