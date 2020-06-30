#!/bin/bash

set -e

# This allows us to override environment variables by updating `/etc/environment`
# and then restarting the container, without needing to recreate the container.
set -o allexport
source /etc/environment

/tmp/check-db-status.sh


if [ ! -e .magento-install-date ]; then
  chmod +x "${BIN_MAGENTO}"
  chmod +x "${BIN_COMPOSER}"

  shopt -s expand_aliases
  source ~/.bashrc

  # Setup `magento` and `composer` aliases

  cat > ~/.bashrc << EOF
  alias magento="${BIN_MAGENTO}"
  alias composer="${BIN_COMPOSER}"
EOF

  echo "Running Magento install script"
  runuser -p -s /bin/bash www-data /tmp/setup-magento.sh
  date > .magento-install-date
fi

if [ ! -e .protect-install-date ] && [ $INSTALL_MODULE = "true" ]; then
  echo "Running Protect install script"
  runuser -p -s /bin/bash www-data  /tmp/setup-protect.sh
  date > .protect-install-date
fi

# Update config in case any environment variables have changed
runuser -p -s /bin/bash www-data /tmp/setup-update-config.sh
echo "Starting cron service ..."
service cron start
echo "Starting Apache ..."
apache2-foreground
