#!/bin/bash

set -e

if [ "${HOME}" != "/var/www" ]; then
  echo "This script assumes it's run by 'www-data' with homedir '/var/www', not $(id)"
  exit 1
fi

# This allows us to override environment variables by updating `/etc/environment`
# and then restarting the container, without needing to recreate the container.
set -o allexport
source /etc/environment

cd "${HOME}"
php ./try-connect-magento-db.php

if [ ! -e .magento-db-create-date ]; then
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

# Update config in case any environment variables have changed
./setup-update-config.sh

# Apache cannot open /dev/stdout when running under supervisord, so we
# remove these links and just have it log to files.
rm /var/log/apache2/*

echo "Starting Apache ..."
apache2-foreground