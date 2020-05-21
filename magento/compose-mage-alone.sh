#!/bin/bash

SCRIPTDIR="$(dirname "$0")"

docker-compose \
  -f "${SCRIPTDIR}/docker-compose.yml" \
  -f "${SCRIPTDIR}/../common/docker-compose.network.yml" \
  -f "${SCRIPTDIR}/../common/docker-compose.database.yml" "$@"
