#!/bin/bash

set -e

if [ "$(pwd)" != "/home/node" ]; then
  echo "This script assumes it's run by 'node' in '/home/node', not $(id) in $(pwd)"
  exit 1
fi

cd ./ns8-template-service

yarn global add pino-pretty
yarn install

yarn dev | "$(yarn global bin)/pino-pretty" \
  --colorize --translateTime --messageFormat
