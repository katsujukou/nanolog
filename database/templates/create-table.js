exports.shorthands = undefined;

/**
 * 
 * @param {import("node-pg-migrate").MigrationBuilder} pgm 
 * @return {Promise<void>}
 */
exports.up = async (pgm) => {
  pgm.createTable("users", {
    id: { type: "uuid", primaryKey: true, default: pgm.func("gen_random_uuid()") },
    createdAt: { type: "timestamptz", notNull: true, default: pgm.func("now()") },
    updatedAt: { type: "timestamptz", notNull: false, default: null }
  });
};

/**
 * 
 * @param {import("node-pg-migrate").MigrationBuilder} pgm 
 * @return {Promise<void>}
 */
exports.down = async (pgm) => {
  pgm.dropTable("users");
};
