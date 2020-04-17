#!/bin/bash

set -e

# Setup `magento` and `composer` aliases
MAGENTO_INSTALL_DIR=/var/www/html
BIN_MAGENTO="${MAGENTO_INSTALL_DIR}/bin/magento"
COMPOSER_BIN="${MAGENTO_INSTALL_DIR}/vendor/composer/composer/bin/composer"

chmod +x "${BIN_MAGENTO}"
chmod +x "${COMPOSER_BIN}"
cat > ~/.bashrc << EOF
alias magento="${BIN_MAGENTO}"
alias composer="${COMPOSER_BIN}"
EOF

shopt -s expand_aliases
source ~/.bashrc

# Setup Magento composer repo auth
cd "${MAGENTO_INSTALL_DIR}"
jq --arg pubkey "${MAGE_COMPOSER_REPO_PUBKEY}" \
  --arg privkey "${MAGE_COMPOSER_REPO_PRIVKEY}" \
  '.["http-basic"]["repo.magento.com"]=({
    "username": $pubkey,
    "password": $privkey
  })' \
  < ./auth.json.sample > ./auth.json

# Install Protect SDK via composer & update config
declare -a REQUIRE_ARGS
REQUIRE_ARGS=("ns8/protect-sdk")
if [ "${INSTALL_DEV_PHP_SDK}" = "1" ]; then
  REQUIRE_ARGS+=("dev-dev")
fi
composer require "${REQUIRE_ARGS[@]}"

# Update the php sdk config; need to do this before
# running the magento installer, since it will fail
# if it cannot hit protect to get an auth token
~/setup-update-config.sh

# Link Magento module src to './app/code/NS8/Protect'
PROTECT_MODULE_DIR="$(realpath ./app)/code/NS8/Protect"
mkdir -p "$(dirname "${PROTECT_MODULE_DIR}")"
ln -s "$(realpath "${MODULE_SRC}")" "${PROTECT_MODULE_DIR}"

# Install Protect
if ! magento setup:upgrade; then
  printf "\n\n *** magento setup:upgrade failed *** \n\n"
  if [ "${INSTALL_DEV_PHP_SDK}" != "1" ]; then
    exit 1
  fi
fi

magento cron:install
magento cache:clean
