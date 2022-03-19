const jsonwebtoken = require('jsonwebtoken');
const util = require('util');

exports._sign = function (payload, secret, opts) {
  const opts_ = Object.keys(opts).reduce((acc, k) => {
    if (opts[k] !== null) {
      acc[k] = opts[k];
    }
    return acc;
  }, {})

  return util.promisify(jsonwebtoken.sign)(JSON.parse(payload), secret, opts_)
}
exports._verify = function (Left, Right, Tuple, token, secret, opts) {
  const opts_ = Object.keys(opts).reduce((acc, key) => {
    if (opts[key] !== null) {
      acc[key] = opts[key];
    }
    return acc;
  }, {});

  return util.promisify(jsonwebtoken.verify)(token, secret, opts_)
    .then(payload => Promise.resolve(Right(payload)))
    .catch(e => {
      if ( e instanceof jsonwebtoken.JsonWebTokenError
        || e instanceof jsonwebtoken.NotBeforeError
        || e instanceof jsonwebtoken.TokenExpiredError
        ) {
          return Promise.resolve(Left(Tuple(e.message)(false)));
        }
        else {
          return Promise.resolve(Left(Tuple(e.message)(true)));
        }
    });
}