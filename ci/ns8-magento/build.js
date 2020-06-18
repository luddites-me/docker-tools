const childProcess = require("child_process");
const cli = require("cli");
const dockerfileTemplate = require("dockerfile-template");
const fs = require("fs");
const objectKeysNormalizer = require("object-keys-normalizer");

const options = cli.parse({
  "magento-version": [ "m", "The version of Magento to use (required)", "string" ],
  "php-version": [ "p", "The version of PHP to use (required)", "string" ],
});

if (!options["magento-version"] || !options["php-version"]) {
  console.log("Please use -h for help.");
  process.exit(1);
}

console.log("Building your Docker image with these options:", options);
const tag = options["php-version"] + "-" + options["magento-version"];

try {
  const template = fs.readFileSync("./ns8-magento/Dockerfile.template", "utf8");

  const child = childProcess.spawn(
    "docker",
    [ "build", "-t", "ns8-magento:" + tag, "-" ],
    { stdio: [ "pipe", "inherit", "inherit" ] }
  );

  const dockerfile = dockerfileTemplate.process(
    template,
    objectKeysNormalizer.normalizeKeys(options, (key) => key.toUpperCase().replace("-", "_"))
  );

  child.stdin.write(dockerfile);
  child.stdin.end();
} catch (error) {
  console.error(error);
}
