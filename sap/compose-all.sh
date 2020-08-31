#!/bin/bash

SCRIPTDIR="$(dirname "$0")"

# Change to script dir to make sure correct .env is loaded
cd "${SCRIPTDIR}" || exit 1

docker-compose \
  -f "./docker-compose.yml" \
  -f "../common/docker-compose.network.yml" \
  -f "../common/docker-compose.database.mysql.yml" \
  -f "../kafka/docker-compose.yml" \
  -f "../protect-api/docker-compose.yml" \
  -f "../protect-client/docker-compose.yml" "$@"
