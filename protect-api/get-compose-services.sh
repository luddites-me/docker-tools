#!/bin/bash

set -euo pipefail

SCRIPTDIR="$(dirname "$0")"

if [ -z "${PROTECT_API_COMPOSE_MYSQL}" ] && \
    [ -z "${PROTECT_API_COMPOSE_POSTGRES}" ]; then
    echo "Must set PROTECT_API_COMPOSE_MYSQL or PROTECT_API_COMPOSE_POSTGRES" 1>&2
    exit 1
fi

if [ -n "${PROTECT_API_COMPOSE_POSTGRES}" ]; then
  if [ -z "${POSTGRES_USERNAME}" ] || \
    [ -z "${POSTGRES_PASSWORD}" ]; then
    echo "Must set POSTGRES_USERNAME and POSTGRES_PASSWORD if PROTECT_API_COMPOSE_POSTGRES is set" 1>&2
    exit 1
  fi
fi

if [ -n "${COMPOSE_PROTECT_CLIENT}" ] && \
    [ -z "${PROTECT_CLIENT_URL}" ]; then
    echo "Should set PROTECT_CLIENT_URL when composing the API with the Client" 1>&2
    echo "(i.e, COMPOSE_PROTECT_CLIENT is set):" 1>&2
    echo 'add `PROTECT_CLIENT_URL="https://${PROTECT_CLIENT_SUBDOMAIN}.ngrok.io"` to .env'  1>&2
    exit 1
fi

if [ -n "${COMPOSE_TEMPLATE_SERVICE}" ] && \
    [ -z "${TEMPLATE_SERVICE_URL}" ]; then
    echo "Should set TEMPLATE_SERVICE_URL when composing the API with the Template Service" 1>&2
    echo "(i.e, COMPOSE_TEMPLATE_SERVICE is set):" 1>&2
    echo 'add `TEMPLATE_SERVICE_URL="https://${TEMPLATE_SERVICE_SUBDOMAIN}.ngrok.io"` to .env'  1>&2
    exit 1
fi

realpath "${SCRIPTDIR}/../common/docker-compose.network.yml"
realpath "${SCRIPTDIR}/../common/docker-compose.database.dynamo.yml"
if [ -n "${PROTECT_API_COMPOSE_PGADMIN}" ]; then
    realpath "${SCRIPTDIR}/../common/docker-compose.pgadmin.yml"
fi
if [ -n "${PROTECT_API_COMPOSE_POSTGRES}" ]; then
    realpath "${SCRIPTDIR}/../common/docker-compose.database.postgres.yml"
fi
if [ -n "${PROTECT_API_COMPOSE_MAILCATCHER}" ]; then
    echo "'PROTECT_API_COMPOSE_MAILCATCHER' Not Yet Implemented" 1>&2
fi
if [ -n "${PROTECT_API_COMPOSE_MYSQL}" ]; then
    realpath "${SCRIPTDIR}/../common/docker-compose.database.mysql.yml"
fi
realpath "${SCRIPTDIR}/docker-compose.yml"
