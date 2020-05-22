#!/bin/bash

set -e

if [ "$(pwd)" != "/home/node" ]; then
  echo "This script assumes it's run by 'node' in '/opt', not $(id)"
  exit 1
fi

./create-dynamodb-tables.sh

cd ./ns8-protect-api
# Install dependencies
if [ -d node_modules ]; then
  echo "WARNING: 'node_modules' already exists"
  echo "WARNING: if you see 'Error: '<YOUR_PLATFORM>' binaries cannot be used on the 'linuxmusl-x64' platform'"
  echo "WARNING: then 'rm -rf node_modules' and restart the container"
fi
yarn install --frozen-lockfile

if [ ! -e "./config/${APP_ENV}.yml" ]; then
  echo "WARNING: 'APP_ENV' has no corresponding config file './config/${APP_ENV}.yml'"
fi

START_CMD="node --inspect=0.0.0.0:9229 -r ts-node/register -r dotenv/config src/main.ts"
yarn nodemon -V -e ts -w src -x "${START_CMD}" \
  | npx pino-pretty --colorize --translateTime