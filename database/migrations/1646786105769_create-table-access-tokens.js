exports.shorthands = undefined;

/**
 * 
 * @param {import("node-pg-migrate").MigrationBuilder} pgm 
 * @return {Promise<void>}
 */
exports.up = async (pgm) => {
  await pgm.createTable('access_tokens', {
    id: { type: "uuid", primaryKey: true, default: pgm.func("gen_random_uuid()") },
    userId: { type: "uuid", notNull: true },
    createdAt: { type: "timestamptz", notNull: true, default: pgm.func("current_timestamp") },
    revokedAt: { type: "timestamptz", notNull: false, default: null },
    updatedAt: { type: "timestamptz", notNull: false, default: null }
  });

  await pgm.createIndex('access_tokens', ['userId']);

  await pgm.createTrigger('access_tokens', 'update_updated_at_trig', {
    when: "BEFORE",
    operation: "UPDATE",
    level: "ROW",
    function: "set_update_time",
    functionParams: [],
  });
};

/**
 * 
 * @param {import("node-pg-migrate").MigrationBuilder} pgm 
 * @return {Promise<void>}
 */
exports.down = async (pgm) => {
  pgm.dropTrigger("access_tokens", "update_updated_at_trig");
  pgm.dropIndex('access_tokens', ['userId'])
  pgm.dropTable('access_tokens');
};