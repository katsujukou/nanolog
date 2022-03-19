import { bundle, logError, mergeBuildReport, printBuildResult, __dirname } from "./build-utils.mjs";
import fsPromises from "fs/promises";
import { execSync } from "child_process";
import fse from "fs-extra";
import { sassPlugin } from 'esbuild-sass-plugin';
import { htmlPlugin } from '@craftamap/esbuild-plugin-html';
import path from "path";

(async () => {
  const rootDir = path.resolve(__dirname, "..");

  try {
    //==================================================================================================
    // バックエンドのビルド
    //==================================================================================================
    const backendReport = await bundle({
      buildEnv: "dev",
      clean: true,
      entryPoints: ["app/backend/main.js"],
      outdir: "backend",
      configureEsbuild: {
        platform: "node",
        external: [
          "pg-native",
        ],
        banner: {
          js: "#!/usr/bin/env node",
        }
      },
      onSuccess: async () => {
        await fsPromises.mkdir("dist/dev/backend/bin");
        fse.copySync("app/backend/assets/conf", "dist/dev/backend/conf");
        await fsPromises.copyFile("app/backend/assets/config.js", "dist/dev/backend/config.js");
        await fsPromises.copyFile("app/backend/assets/.env.example", "dist/dev/backend/.env");
        await fsPromises.rename("dist/dev/backend/main.js", "dist/dev/backend/bin/nanolog-cli");
        execSync("chmod +x dist/dev/backend/bin/nanolog-cli");
      }
    });

    //==================================================================================================
    // フロントエンドのビルド
    //==================================================================================================
    const htmlTemplate = await fsPromises.readFile(path.join(rootDir, 'app/frontend/index.template.html'));
    const frontendReport = await bundle({
      buildEnv: 'dev',
      clean: true,
      outdir: 'frontend',
      entryPoints: ['app/frontend/index.js'],
      configureEsbuild: {
        entryNames: '[name].[hash]',
        metafile: true,
        publicPath: "/",
        external: ["xhr2", "url"],
        plugins: [
          sassPlugin(),
          htmlPlugin({
            files: [
              {
                filename: 'index.html',
                entryPoints: ['app/frontend/index.js', 'app/frontend/css/index.sass'],
                htmlTemplate,
              }
            ]
          })
        ]
      }
    })

    printBuildResult(mergeBuildReport(backendReport, frontendReport));
  }
  catch (e) {
    console.error(e, "\n");
    logError("Failed to bundle app.");
  }
})();