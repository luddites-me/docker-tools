#!/bin/bash

set -euo pipefail

SCRIPTDIR="$(dirname "$0")"

realpath "${SCRIPTDIR}/../common/docker-compose.network.yml"
realpath "${SCRIPTDIR}/docker-compose.yml"
