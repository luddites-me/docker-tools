#!/bin/bash

set -e

# Setup `magento` and `composer` aliases
chmod +x ./vendor/composer/composer/bin/composer
cat > ~/.bashrc << EOF
alias magento="/var/www/html/bin/magento"
alias composer="/var/www/html/vendor/composer/composer/bin/composer"
alias req-dev-php-sdk="(cd /var/www/html && composer require ns8/protect-sdk dev-dev && ./setup-update-config.sh)"
EOF

shopt -s expand_aliases
source ~/.bashrc


# Setup Magento composer repo auth
jq --arg pubkey "${MAGE_COMPOSER_REPO_PUBKEY}" \
  --arg privkey "${MAGE_COMPOSER_REPO_PRIVKEY}" \
  '.["http-basic"]["repo.magento.com"]=({
    "username": $pubkey,
    "password": $privkey
  })' \
  < auth.json.sample > auth.json

# Install Protect SDK via composer & update config
composer require ns8/protect-sdk
./setup-update-config.sh

# Link Magento module src to './app/code/NS8/Protect'
PROTECT_MODULE_DIR="$(realpath ./app)/code/NS8/Protect"
mkdir -p "$(dirname "${PROTECT_MODULE_DIR}")"
ln -s "$(realpath "${MODULE_SRC}")" "${PROTECT_MODULE_DIR}"

# Install Protect
magento setup:upgrade

magento cache:clean
