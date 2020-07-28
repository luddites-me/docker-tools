#!/bin/bash

set -e

SCRIPTDIR="$(dirname "$0")"

if [ -n "${V1_API_SERVICE_MONGODB}" ]; then
  if [ -z "${MONGO_USERNAME}" ] || \
    [ -z "${MONGO_PWD}" ]; then
    echo "Must set MONGO_USERNAME and MONGO_PASSWORD if V1_API_SERVICE_MONGODB is set" 1>&2
    exit 1
  fi
fi

realpath "${SCRIPTDIR}/../common/docker-compose.network.yml"
if [ -n "${V1_API_SERVICE_MONGODB}" ]; then
    realpath "${SCRIPTDIR}/docker-compose.database.mongodb.yml"
fi
realpath "${SCRIPTDIR}/docker-compose.yml"
