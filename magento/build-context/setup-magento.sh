#!/bin/bash

set -e

# Setup Magento composer repo auth
cd "${MAGENTO_INSTALL_DIR}"
jq --arg pubkey "${MAGE_COMPOSER_REPO_PUBKEY}" \
  --arg privkey "${MAGE_COMPOSER_REPO_PRIVKEY}" \
  '.["http-basic"]["repo.magento.com"]=({
    "username": $pubkey,
    "password": $privkey
  })' \
  < ./auth.json.sample > ./auth.json
if [ $INSTALL_DATA = "true" ] ; then
  php "${BIN_MAGENTO}" sampledata:deploy
fi
php -dmemory_limit=8G "${BIN_MAGENTO}" setup:install \
  --language=en_US \
  --timezone=America/Los_Angeles \
  --db-host=mysql \
  --db-name="${MYSQL_DATABASE}" \
  --db-user="${MYSQL_USER}" \
  --db-password="${MYSQL_PASSWORD}" \
  --backend-frontname="${BACKOFFICE_PATH}" \
  --admin-firstname=Development \
  --admin-lastname=Testing \
  --admin-email=dev@ns8demos.com \
  --admin-user="${BACKOFFICE_USERNAME}" \
  --admin-password="${BACKOFFICE_PASSWORD}" \
  --base-url="${MAGENTO_BASE_URL}" \
  --base-url-secure="${MAGENTO_BASE_URL}" \
  --use-secure=1 \
  --use-secure-admin=1

php "${BIN_MAGENTO}" cache:clean
