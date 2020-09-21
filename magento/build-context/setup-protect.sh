#!/bin/bash

set -euo pipefail
# Setup Magento composer repo auth
cd "${MAGENTO_INSTALL_DIR}"


if [ "${INSTALL_DEV_PHP_SDK}" = "true" ]; then
    ${BIN_COMPOSER} config repositories.2 path $SDK_SRC
fi

if [ "${INSTALL_DEV_MODULE}" = "true" ]; then
  echo "Loading the protect module from the filesystem"
  PROTECT_VERSION=$(cat "${MODULE_SRC}/composer.json" | jq -r .version)
  ${BIN_COMPOSER} config repositories.1 path $MODULE_SRC
  ${BIN_COMPOSER} require --prefer-source luddites/protect-magento:${PROTECT_VERSION}@dev
else
  ${BIN_COMPOSER} require luddites/protect-magento
fi


# Update the php sdk config; need to do this before
# running the magento installer, since it will fail
# if it cannot hit protect to get an auth token
/tmp/setup-update-config.sh



# Install Protect
/tmp/wait-for-protect.sh
if ! ${BIN_MAGENTO} setup:upgrade; then
  printf "\n\n *** magento setup:upgrade failed *** \n\n"
  if [ "${INSTALL_DEV_PHP_SDK}" != "1" ]; then
    exit 1
  fi
fi

if [ "${INSTALL_DEV_MODULE}" = "true" ]; then
  ${BIN_MAGENTO} deploy:mode:set developer
fi

${BIN_MAGENTO} cron:install
${BIN_MAGENTO} cache:clean
${BIN_MAGENTO} setup:di:compile
