const bcrypt = require('bcryptjs');

exports._hash = function (data, rounds) {
  return bcrypt.hash(data, rounds);
}
exports._compare = function (data, hashed) {
  return bcrypt.compare(data, hashed);
}