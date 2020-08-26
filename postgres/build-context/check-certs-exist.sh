#!/bin/bash

SCRIPTDIR="$(dirname "$0")"

echo "Checking for certificate files in ${SCRIPTDIR}"

if [ ! -e "${SCRIPTDIR}/server.key" ]; then
  echo "server.key does not exist"
  exit 1
fi

if [ ! -e "${SCRIPTDIR}/server.cert" ]; then
  echo "server.cert does not exist"
  exit 1
fi

echo "Certificate files exist"
