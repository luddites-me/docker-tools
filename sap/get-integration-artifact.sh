#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: ./get-integration-artifact.sh <outputFile>";
  exit 1;
fi

OUTPUT_FILE="$1"
RELEASE_API_URL="https://api.github.com/repos/ns8inc/protect-integration-sap/releases/latest"

apt-get install -y jq
RELEASE_URL=$(curl -s "$RELEASE_API_URL" | jq -r '.assets[0].url')

if [ "$RELEASE_URL" = "null" ]; then
  echo "ERROR: Couldn't get latest release URL"
  exit 1
fi

curl -s "$RELEASE_URL" > "$OUTPUT_FILE"
