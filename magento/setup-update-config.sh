#!/bin/bash

set -e

if [ "${HOME}" != "/var/www" ]; then
  echo "This script assumes it's run by 'www-data' with homedir '/var/www'"
  exit 1
fi

if [ -z "${MAGENTO_BASE_URL}" ] \
  || [ -z "${PROTECT_API_URL}" ] \
  || [ -z "${PROTECT_CLIENT_URL}" ]; then
  echo "Must define MAGENTO_BASE_URL, PROTECT_API_URL and PROTECT_CLIENT_URL"
  exit 1
fi

pushd  ~/html/vendor/ns8/protect-sdk/assets/configuration
  cp core_configuration.json core_configuration.json.orig
  jq --arg apiUrl "${PROTECT_API_URL}" \
    --arg clientUrl "${PROTECT_CLIENT_URL}" \
    '.default_environment="development"
      | .logging.file += {
          enabled: true
        }
      | .development.urls += {
          api_url: $apiUrl,
          client_url: $clientUrl
        }' \
    < core_configuration.json.orig > core_configuration.json
popd

CURRENT_BASE_URL=$(~/html/bin/magento config:show web/secure/base_url)
if [ "${CURRENT_BASE_URL}" != "${MAGENTO_BASE_URL}" ]; then
  ~/html/bin/magento setup:store-config:set --base-url-secure="${MAGENTO_BASE_URL}"
  ~/html/bin/magento cache:flush
fi
