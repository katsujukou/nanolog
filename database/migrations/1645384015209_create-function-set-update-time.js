exports.shorthands = undefined;

/**
 * 
 * @param {import("node-pg-migrate").MigrationBuilder} pgm 
 * @return {Promise<void>}
 */
exports.up = async (pgm) => {
  await pgm.createFunction(
    "set_update_time",
    [],
    {
      returns: "trigger",
      language: "plpgsql"
    },
    `
    BEGIN
      NEW."updatedAt" = now();
      return NEW;
    END;
    `
  );
};

/**
 * 
 * @param {import("node-pg-migrate").MigrationBuilder} pgm 
 * @return {Promise<void>}
 */
exports.down = async (pgm) => {
  pgm.dropFunction('set_update_time');
};