/* eslint-disable camelcase */

exports.shorthands = undefined;

exports.up = pgm => {
  pgm.createExtension("pgcrypto", { ifNotExists: true });
};

exports.down = pgm => {
  pgm.dropExtension('pgcrypto');
};
