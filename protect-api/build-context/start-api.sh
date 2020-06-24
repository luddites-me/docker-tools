#!/bin/bash

set -e

if [ "$(pwd)" != "/home/node" ]; then
  echo "This script assumes it's run by 'node' in '/opt', not $(id)"
  exit 1
fi

if ! ./create-dynamodb-tables.sh; then
  echo "ERROR: error creating dynamodb tables"
  exit 1
fi

if [ -z "${PROTECT_API_COMPOSE_MYSQL}" ] && \
    [ -z "${PROTECT_API_COMPOSE_POSTGRES}" ]; then
    echo "Must set PROTECT_API_COMPOSE_MYSQL or PROTECT_API_COMPOSE_POSTGRES" 1>&2
    echo " ${PROTECT_API_COMPOSE_MYSQL}; ${PROTECT_API_COMPOSE_POSTGRES}" 1>&2
    exit 1
fi

if [ -n "${PROTECT_API_COMPOSE_POSTGRES}" ]; then
  if [ -z "${POSTGRES_USERNAME}" ] || \
    [ -z "${POSTGRES_PASSWORD}" ]; then
    echo "Must set POSTGRES_PASSWORD and POSTGRES_PASSWORD if PROTECT_API_COMPOSE_POSTGRES is set" 1>&2
    exit 1
  fi
fi

declare -a CONFIG_OVERRIDE_OPTS
if [ -z "${PROTECT_API_NO_CONFIG_OVERRIDES}" ]; then
  DB_TYPE="postgres"
  if [ -n "${PROTECT_API_COMPOSE_MYSQL}" ]; then
    DB_TYPE="mysql"
  fi
  echo "Setting 'dbConnector.type' to '${DB_TYPE}'"
  CONFIG_OVERRIDE_OPTS+=("dbConnector.type=${DB_TYPE}")
  echo "Setting 'dbConnector.host' to '${DB_TYPE}'"
  CONFIG_OVERRIDE_OPTS+=("dbConnector.host=${DB_TYPE}")
  if [ -n "${PROTECT_API_COMPOSE_MYSQL}" ]; then
    DB_TYPE="mysql"
  fi

  if [ -n "${PROTECT_API_COMPOSE_POSTGRES}" ]; then
    if [ -z "${POSTGRES_USERNAME}" ] || \
      [ -z "${POSTGRES_PASSWORD}" ]; then
      echo "Must set POSTGRES_USERNAME and POSTGRES_PASSWORD if PROTECT_API_COMPOSE_POSTGRES is set" 1>&2
    fi
    echo "Setting 'dbConnector.username' to ${POSTGRES_USERNAME}"
    CONFIG_OVERRIDE_OPTS+=("dbConnector.username=${POSTGRES_USERNAME}")
    echo "Setting 'dbConnector.password' to ${POSTGRES_PASSWORD}"
    CONFIG_OVERRIDE_OPTS+=("dbConnector.password=${POSTGRES_PASSWORD}")
  fi

  echo "Setting 'dynamoEndpoint' to '${DYNAMODB_ENDPOINT_URL}'"
  CONFIG_OVERRIDE_OPTS+=("dynamoEndpoint=${DYNAMODB_ENDPOINT_URL}")

  echo "Setting 'ns8ApiHost' to '${PROTECT_API_URL}'"
  CONFIG_OVERRIDE_OPTS+=("ns8ApiHost=${PROTECT_API_URL}")

  if [ -n "${PROTECT_CLIENT_URL}" ]; then
    echo "Setting 'ns8FrontEndUrl' to '${PROTECT_CLIENT_URL}'"
    CONFIG_OVERRIDE_OPTS+=("ns8FrontEndUrl=${PROTECT_CLIENT_URL}")
  fi

  if [ -n "${TEMPLATE_SERVICE_URL}" ]; then
    echo "Setting 'ns8TemplateHostUrl' to ${TEMPLATE_SERVICE_URL}"
    CONFIG_OVERRIDE_OPTS+=("ns8TemplateHostUrl=${TEMPLATE_SERVICE_URL}")
  fi
fi


cd ./ns8-protect-api
# Install dependencies
if [ -d node_modules ]; then
  echo "WARNING: 'node_modules' already exists"
  echo "WARNING: if you see 'Error: '<YOUR_PLATFORM>' binaries cannot be used on the 'linuxmusl-x64' platform'"
  echo "WARNING: then 'rm -rf node_modules' and restart the container"
fi
yarn install

if [ ! -e "./config/${APP_ENV}.yml" ]; then
  echo "WARNING: 'APP_ENV' has no corresponding config file './config/${APP_ENV}.yml'"
fi

if [ -n "${NO_DEBUG}" ]; then
  yarn build && node -r dotenv/config dist/main.js "${CONFIG_OVERRIDE_OPTS[@]}" \
    | npx pino-pretty --colorize --translateTime
else
  START_CMD="node --inspect=0.0.0.0:9229 -r ts-node/register -r dotenv/config src/main.ts ${CONFIG_OVERRIDE_OPTS[*]}"
  yarn nodemon -V -e ts -w src -x "${START_CMD}" \
    | npx pino-pretty --colorize --translateTime
fi
