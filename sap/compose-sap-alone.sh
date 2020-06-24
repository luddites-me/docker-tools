#!/bin/bash

SCRIPTDIR="$(dirname "$0")"

# Change to script dir to make sure correct .env is loaded
cd "${SCRIPTDIR}" || exit 1

docker-compose \
  -f "./docker-compose.yml" \
  -f "../common/docker-compose.network.yml" \
  $*
