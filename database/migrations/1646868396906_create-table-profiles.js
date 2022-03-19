exports.shorthands = undefined;

/**
 * 
 * @param {import("node-pg-migrate").MigrationBuilder} pgm 
 * @return {Promise<void>}
 */
exports.up = async (pgm) => {
  await pgm.createTable('profiles', {
    id: { type: "uuid", primaryKey: true, default: pgm.func("gen_random_uuid()") },
    userId: { type: "uuid", notNull: true },
    nickname: { type: "varchar(50)", notNull: false },
    thumbnail: { type: "text", notNull: false },
    createdAt: { type: "timestamptz", notNull: true, default: pgm.func("current_timestamp") },
    updatedAt: { type: "timestamptz", notNull: false, default: null }
  });

  await pgm.createIndex('profiles', ['userId']);

  await pgm.createTrigger('profiles', 'update_updated_at_trig', {
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
  await pgm.dropTrigger("profiles", "update_updated_at_trig");
  await pgm.dropIndex('profiles', ['userId'])
  await pgm.dropTable('profiles');
};