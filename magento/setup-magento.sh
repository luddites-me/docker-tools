#!/bin/bash

set -e

chmod +x bin/magento

bin/magento setup:install \
  --language=en_US \
  --timezone=America/Los_Angeles \
  --db-host=mysql \
  --db-name=magento2 \
  --db-user=magento_db_user \
  --db-password=magento_db_password \
  --backend-frontname=admin_demo \
  --admin-firstname=Development \
  --admin-lastname=Testing \
  --admin-email=dev@ns8demos.com \
  --admin-user=development \
  --admin-password=YzbLenbGRGN6fxqNsz.ti \
  --base-url-secure="${MAGENTO_BASE_URL}" \
  --use-secure=1 \
  --use-secure-admin=1

bin/magento cache:clean
