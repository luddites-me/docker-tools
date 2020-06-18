const childProcess = require("child_process");
const cli = require("cli");
const dockerfileTemplate = require("dockerfile-template");
const fs = require("fs");
const objectKeysNormalizer = require("object-keys-normalizer");

const options = cli.parse({
  "php-version": [ "p", "The version of PHP to use (required)", "string" ],
});

if (!options["php-version"]) {
  console.log("Please use -h for help.");
  process.exit(1);
}

console.log("Building your Docker image with these options:", options);

try {
  const template = fs.readFileSync("./ns8-php/Dockerfile.template", "utf8");

  const child = childProcess.spawn(
    "docker",
    [ "build", "-t", "ns8-php:" + options["php-version"] , "-" ],
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
