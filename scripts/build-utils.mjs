import esbuild from "esbuild";
import path from "path";
import url from "url";
import dayjs from "dayjs";
import fs from "fs";
import fsPromises from "fs/promises";
import prettyByte from "pretty-byte";

export const __dirname = path.dirname(url.fileURLToPath(import.meta.url));

export function allFiles (p) {
  const result = [];
  const files =fs.readdirSync(p);

  files.forEach((file) => {
    const joined =p+"/"+file;
    const stat = fs.statSync(joined);
    if (stat.isFile()) {
      result.push(joined);
    }
    else if (stat.isDirectory()) {
      const sub = allFiles(joined);
      result.push(...sub)
    }
  });

  return result;
} 

/**
 * @typedef {"prod"|"dev"} BuildEnv
 * @typedef {object} BundleOptions
 * @property {BuildEnv} buildEnv
 * @property {?string} outdir
 * @property {?string} outfile
 * @property {string[]} entryPoints
 * @property {?esbuild.BuildOptions} configureEsbuild
 * @property {?boolean} addShebang
 * 
 * @param {BundleOptions} options
 * @return {Promise<BuildReport>}
 */
export async function bundle (options) {
  const rootDir = path.resolve(__dirname, "..");
  const outdir = path.join('dist', options.buildEnv, options.outdir ?? "");

  /** @type {esbuild.BuildOptions} overrideEsbuild */
  const overrideEsbuild = {
    absWorkingDir: rootDir,
    bundle: true,
    entryPoints: options.entryPoints,
    outdir: outdir,
    metafile: true,
    minify: options.buildEnv === "prod", 
    nodePaths: [
      ...(options.configureEsbuild?.nodePaths ?? []),
      options.buildEnv === "prod" ? "dce-output" : "output"
    ],
  };

  if (!fs.existsSync(outdir)) {
    fs.mkdirSync(outdir);
  }
  else {
    if (options.clean) {
      fs.readdirSync(outdir)
        .forEach((file) => {
          fs.rmSync(path.join(outdir, file), { recursive: true, force: true })
        })
    }  
  }

  const from = dayjs().valueOf();
  await esbuild.build(Object.assign({}, options.configureEsbuild ?? {}, overrideEsbuild));
  if (options.onSuccess !== undefined) {
    await options.onSuccess();
  }
  return allFiles(`dist/${options.buildEnv}`).reduce((acc, file) => {
    acc.files[file] = fs.statSync(file).size;
    return acc;
  }, { files: {}, totalBuildTime: dayjs().valueOf() - from });
}

/**
 * 
 * @param {BuildReport} r1 
 * @param {BuildReport} r2 
 * @return {BuildReport}
 */
export function mergeBuildReport (r1, r2) {
  return {
    totalBuildTime: r1.totalBuildTime + r2.totalBuildTime,
    files: Object.assign({}, r1.files, r2.files)
  }
}

/**
 * 
 * @param {BuildReport} report 
 */
export function printBuildResult (report) {
  console.log("\n\x1b[1;34m[Build Info]\x1b[0m");
  let sizelog = "";
  let totalSize = 0;
  for (const file in report.files) {
    const size = report.files[file]
    totalSize += size;
    sizelog += `    - ${file} ... \x1b[1;32m${prettyByte(size)}\x1b[0m` + "\n";
  }
  console.log(`\x1b[33m  ✔ Total bundle size\x1b[0m: ... \x1b[1;32m${prettyByte(totalSize)}\x1b[0m`);
  console.log(sizelog)
  console.log(`\x1b[33m  ✔ Total bundle time\x1b[0m ... \x1b[1;32m${report.totalBuildTime} msec\x1b[0m`);
}

/**
 * @param {"info"|"warn"|"error"} level 
 */
const logMessage = (level) => (message) => {
  const prefix = ((level) => {
    if (level === "info") return "\x1b[34m[INFO]\x1b[0m "
    else if (level === "warn") return "\x1b[32m[WARN]\x1b[0m "
    else if (level === "error") return "\x1b[31m[ERROR]\x1b[0m "
  })(level);
  console.log(prefix + message);
}

export const logInfo = logMessage("info");
export const logError = logMessage("error");
