const { spawn } = require('cross-spawn');
const dotEnvExtended = require('dotenv-extended');
const dotenvExpand = require('dotenv-expand');


const parseArgs = () => {
  const defaultAndSchemaDirList = [__dirname];
  defaultAndSchemaDirList.push(
    ...process.argv.map((arg) => {
      const m = arg.match(/--schemaDir=(.+)/);
      return m && m[1];
    }).filter((parsedArg) => parsedArg != null));
  return defaultAndSchemaDirList;
}

const loadEnv = () => {
  // load defaults for each service
  const defaultAndSchemaDirList = parseArgs();
  defaultAndSchemaDirList.forEach((defaultAndSchemaDir) => {
    dotEnvExtended.load({
      assignToProcessEnv: true,
      defaults: `${defaultAndSchemaDir}/.env.defaults`,
      overrideProcessEnv: Boolean(process.env.ENVFILE_TAKES_PRECEDENCE || false),
      path: `${__dirname}/.env`,
    });
  });

  // check schema for each service
  defaultAndSchemaDirList.forEach((defaultAndSchemaDir) => {
    dotEnvExtended.load({
      errorOnMissing: true,
      includeProcessEnv: true,
      path: `${__dirname}/.env`,
      schema: `${defaultAndSchemaDir}/.env.schema`,
    });
  });

  // expand interpolated variables
  env = dotenvExpand({ parsed: process.env }).parsed;

  // echo back the augmented environment so it can be applied / eval'd
  // in parent process
  spawn.sync('bash', ['-c', 'export -p'], {
    env,
    stdio: 'inherit',
    shell: false,
  });
}

if (require.main === module) {
  loadEnv();
}
