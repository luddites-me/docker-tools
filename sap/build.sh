#!/bin/sh

set -e

S3_ARTIFACT_BUCKET="protect-docker-artifacts"
S3_HYBRIS_URL="s3://$S3_ARTIFACT_BUCKET/hybris.zip"
S3_CONNECTOR_URL="s3://$S3_ARTIFACT_BUCKET/hybris-connector.zip"

IMAGE_NAME="244249143763.dkr.ecr.us-west-2.amazonaws.com/protect-integration-hybris-dev-ah"

if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: aws-cli is not installed.' >&2
  exit 1
fi

echo "Checking AWS credentials..."
# this will throw if auth is invalid (usually MFA)
aws s3 ls "s3://$S3_ARTIFACT_BUCKET" > /dev/null

signedHybrisUrl=$(aws s3 presign $S3_HYBRIS_URL)
signedConnectorUrl=$(aws s3 presign $S3_CONNECTOR_URL)

echo "Warning: this will take >40 minutes to build!"

sleep 3

docker build --build-arg "HYBRIS_URL=$signedHybrisUrl" --build-arg "CONNECTOR_URL=$signedConnectorUrl" -t hybris -t "$IMAGE_NAME" .

docker tag hybris "$IMAGE_NAME"

kill $!
