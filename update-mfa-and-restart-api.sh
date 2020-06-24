#!/bin/bash

set -e

SCRIPTDIR="$(dirname "$0")"

AWS_PROFILE=ns8-development get-aws-creds > /dev/null

# we could `restart`, but remove and recreate instead to clear the logs as well
"${SCRIPTDIR}/compose-all.sh" rm -s -f protect-api \
    && "${SCRIPTDIR}/compose-all.sh" up -d
