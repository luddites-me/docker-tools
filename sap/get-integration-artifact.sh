#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: ./get-integration-artifact.sh <outputFile>"
  exit 1
fi

if [ -f hybris-connector.zip ]; then
  echo "Connector artifact copied from local dir, not downloading latest release."
  exit 0
fi

OUTPUT_FILE="$1"

RELEASE_API_URL="https://api.github.com/repos/luddites-me/protect-integration-sap/releases/latest"

apt-get install -y jq
RELEASE_URL=$(curl -s "$RELEASE_API_URL" | jq -r '.assets[0].url')

if [ "$RELEASE_URL" = "null" ]; then
  echo "ERROR: Couldn't get latest release URL"
  exit 1
fi

curl -s "$RELEASE_URL" > "$OUTPUT_FILE"
