#!/bin/bash

set -e

if [ "${HOME}" != "/var/www" ]; then
  echo "This script assumes it's run by 'www-data' with homedir '/var/www'"
  exit 1
fi

if [ -z "${PROTECT_API_URL}" ] || [ -z "${PROTECT_CLIENT_URL}" ]; then
  echo "Must define PROTECT_API_URL and PROTECT_CLIENT_URL"
  exit 1
fi

pushd  ~/html/vendor/ns8/protect-sdk/assets/configuration
  cp core_configuration.json core_configuration.json.orig
  jq --arg apiUrl "${PROTECT_API_URL}" \
    --arg clientUrl "${PROTECT_CLIENT_URL}" \
    '.default_environment="development"
      | .development.urls += {
          api_url: $apiUrl,
          client_url: $clientUrl
      }' \
    < core_configuration.json.orig > core_configuration.json
popd
