#!/bin/bash

set -e

if [ "$(pwd)" != "/home/node" ]; then
  echo "This script assumes it's run by 'node' in '/opt', not $(id)"
  exit 1
fi

cd ./luddites-api-host
# Install dependencies
yarn install

if [ -n "${NO_DEBUG}" ]; then
  yarn build && node app.js
else
 yarn build && node --inspect=0.0.0.0:9229 app.js
fi
