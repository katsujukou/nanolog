const cliConfig = require("./conf/cli.config");
const serverConfig = require("./conf/server.config");

module.exports = {
  ...cliConfig,
  server: serverConfig
}