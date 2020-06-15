#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: ./get-integration-artifact.sh <outputFile>";
  exit 1;
fi

OUTPUT_FILE="$1"
RELEASE_API_URL="https://api.github.com/repos/ns8inc/protect-integration-sap/releases/latest"

apt-get install -y curl jq wget
RELEASE_URL=$(curl "$RELEASE_API_URL" | jq -r '.assets[0].url')

wget -O "$OUTPUT_FILE" -nv "$RELEASE_URL"
