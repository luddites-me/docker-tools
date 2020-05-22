#!/bin/bash

set -e

if [ "$(pwd)" != "/home/node" ]; then
  echo "This script assumes it's run by 'node' in '/home/node', not $(id) in $(pwd)"
  exit 1
fi

cd ./ns8-protect-client

pushd middleware
  # Nice for logging middleware output
  yarn global add pino-pretty
  yarn install --frozen-lockfile
  yarn start:dev | "$(yarn global bin)/pino-pretty" \
    --colorize --translateTime --messageFormat &
popd

cd client
yarn install --frozen-lockfile
yarn start

