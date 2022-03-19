exports.shorthands = undefined;

/**
 * 
 * @param {import("node-pg-migrate").MigrationBuilder} pgm 
 * @return {Promise<void>}
 */
exports.up = async (pgm) => {
  await pgm.createTable('users', {
    id: { type: "uuid", primaryKey: true, default: pgm.func("gen_random_uuid()") },
    email: { type: "varchar(255)", notNull: true, unique: true },
    password: { type: "varchar(255)", notNull: true, },
    createdAt: { type: "timestamptz", notNull: true, default: pgm.func("current_timestamp") },
    updatedAt: { type: "timestamptz", notNull: false, default: null }
  });

  await pgm.createIndex('users', ['email'], { unique: true });

  await pgm.createTrigger('users', 'update_updated_at_trig', {
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
  pgm.dropTrigger("users", "update_updated_at_trig");
  pgm.dropIndex('users', ['email'], { unique: true })
  pgm.dropTable('users');
};