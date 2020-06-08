#!/bin/bash

set -e

if [ "$(pwd)" != "/home/node" ]; then
  echo "This script assumes it's run by 'node' in '/opt', not $(id)"
  exit 1
fi

if ! ./create-dynamodb-tables.sh; then
  echo "ERROR: error creating dynamodb tables"
  exit 1
fi

cd ./ns8-protect-api
# Install dependencies
if [ -d node_modules ]; then
  echo "WARNING: 'node_modules' already exists"
  echo "WARNING: if you see 'Error: '<YOUR_PLATFORM>' binaries cannot be used on the 'linuxmusl-x64' platform'"
  echo "WARNING: then 'rm -rf node_modules' and restart the container"
fi
yarn install

if [ ! -e "./config/${APP_ENV}.yml" ]; then
  echo "WARNING: 'APP_ENV' has no corresponding config file './config/${APP_ENV}.yml'"
fi

if [ -n "${NO_DEBUG}" ]; then
  yarn build && node -r dotenv/config dist/main.js \
    | npx pino-pretty --colorize --translateTime
else
  START_CMD="node --inspect=0.0.0.0:9229 -r ts-node/register -r dotenv/config src/main.ts"
  yarn nodemon -V -e ts -w src -x "${START_CMD}" \
    | npx pino-pretty --colorize --translateTime
fi
