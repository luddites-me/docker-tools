#!/bin/bash

set -euo pipefail

if [ -z "${MAGENTO_BASE_URL}" ] \
  || [ -z "${PROTECT_API_URL}" ] \
  || [ -z "${PROTECT_CLIENT_URL}" ]; then
  echo "Must define MAGENTO_BASE_URL, PROTECT_API_URL and PROTECT_CLIENT_URL"
  exit 1
fi
if [ -d "${MAGENTO_INSTALL_DIR}/vendor/ns8/protect-sdk/assets/configuration" ]; then
  pushd  ${MAGENTO_INSTALL_DIR}/vendor/ns8/protect-sdk/assets/configuration
    cp core_configuration.json core_configuration.json.orig
    jq --arg apiUrl "${PROTECT_API_URL}" \
      --arg clientUrl "${PROTECT_CLIENT_URL}" \
      '.default_environment="development"
        | .logging.file += {
            enabled: true,
            log_level: "INFO"
          }
        | .development.urls += {
            api_url: $apiUrl,
            client_url: $clientUrl
          }' \
      < core_configuration.json.orig > core_configuration.json
  popd
fi
CURRENT_BASE_URL=$($BIN_MAGENTO config:show web/secure/base_url)
if [ "${CURRENT_BASE_URL}" != "${MAGENTO_BASE_URL}" ]; then
  $BIN_MAGENTO setup:store-config:set --base-url-secure="${MAGENTO_BASE_URL}"
  $BIN_MAGENTO cache:flush
fi
