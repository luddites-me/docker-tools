#!/bin/bash

set -e

SCRIPTDIR="$(dirname "$0")"

realpath "${SCRIPTDIR}/../common/docker-compose.network.yml"
realpath "${SCRIPTDIR}/docker-compose.yml"
