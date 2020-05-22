#!/bin/bash

# This script just waits until we can hit protect-client and protect-api

set -e

if [ "${HOME}" != "/var/www" ]; then
  echo "This script assumes it's run by 'www-data' with homedir '/var/www', not $(id)"
  exit 1
fi

if [ -z "${PROTECT_API_URL}" ] \
  || [ -z "${PROTECT_CLIENT_URL}" ]; then
  echo "Must define PROTECT_API_URL and PROTECT_CLIENT_URL"
  exit 1
fi

echo "Checking that protect client is up (${PROTECT_CLIENT_URL})"
curl --silent --output /dev/null \
  --connect-timeout 15 --retry 10 --retry-delay 10 \
  "${PROTECT_CLIENT_URL}"

echo "Checking that protect api is up (${PROTECT_CLIENT_URL})"
curl --silent --output /dev/null \
  --connect-timeout 15 --retry 10 --retry-delay 10 \
  "${PROTECT_API_URL}/protect/diagnostic"
