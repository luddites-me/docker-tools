#!/bin/bash

set -euo pipefail

if [ "$(pwd)" != "/home/node" ]; then
  echo "This script assumes it's run by 'node' in '/home/node', not $(id) in $(pwd)"
  exit 1
fi

if [ -n "${PROTECT_API_URL}" ]; then
  echo "Setting 'V2_API_BASE' to '${PROTECT_API_URL%/}/protect'"
  V2_API_BASE="${PROTECT_API_URL%/}/protect"
  export V2_API_BASE
fi

cd ./ns8-template-service

yarn global add pino-pretty
yarn install

yarn dev | "$(yarn global bin)/pino-pretty" \
  --colorize --translateTime --messageFormat
