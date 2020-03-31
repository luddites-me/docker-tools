#!/bin/bash

set -e

if [ "${HOME}" != "/var/www" ]; then
  echo "This script assumes it's run by 'www-data' with homedir '/var/www'"
  exit 1
fi

# This allows us to override environment variables by updating `/etc/environment`
# and then restarting the container, without needing to recreate the container.
set -o allexport
source /etc/environment

php ./try-connect-magento-db.php

if [ ! -e .magento-db-create-date ] && [ "${SKIP_CREATE_MAGENTO_DB}" != "1" ]; then
  echo "Creating Magento database"
  php ./create-magento-db.php
  date > .magento-db-create-date
fi

if [ ! -e .magento-install-date ]; then
  echo "Running Magento install script"
  ./setup-magento.sh
  date > .magento-install-date
fi

if [ ! -e .protect-install-date ]; then
  echo "Running Protect install script"
  ./setup-protect.sh
  date > .protect-install-date
fi

apache2-foreground
