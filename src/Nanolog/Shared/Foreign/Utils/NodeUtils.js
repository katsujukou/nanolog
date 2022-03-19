const { version } = require("./../../app/backend/lib/package.js");
const dotenv = require('dotenv');
const fsPromises = require('fs/promises');

exports._packageVersion = function () {
  return _ => version
}


exports._loadEnvFile = function (envFile) {
  dotenv.config({
    path: envFile
  })  

  console.log(process.env);
}

exports._removeForceRecursive = function (path) {
  return fsPromises.rm(path, {
    recursive: true,
    force: true
  })
}