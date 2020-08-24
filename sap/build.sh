#!/bin/bash

set -euo pipefail

S3_ARTIFACT_BUCKET="protect-docker-artifacts"
S3_HYBRIS_URL="s3://$S3_ARTIFACT_BUCKET/hybris.zip"

IMAGE_PREFIX="244249143763.dkr.ecr.us-west-2.amazonaws.com"
BUILDER_IMAGE="$IMAGE_PREFIX/protect-integration-hybris-builder"
RUNNER_IMAGE="$IMAGE_PREFIX/protect-integration-hybris-runner"

function check_aws () {
  if ! [ -x "$(command -v aws)" ]; then
    echo "Error: aws-cli is not installed." >&2
    exit 1
  fi

  echo "Checking AWS credentials..."
  # this will throw if auth is invalid (usually MFA)
  aws s3 ls "s3://$S3_ARTIFACT_BUCKET" > /dev/null
}

echo "Warning: this will take a long time to build!"

TARGET="$1"

if [ "$TARGET" = "builder" ]; then
  # only need AWS / S3 for the builder image
  check_aws

  docker build \
    --build-arg "S3_HYBRIS_URL=$S3_HYBRIS_URL" \
    --build-arg "AWS_ACCESS_KEY_ID" \
    --build-arg "AWS_SECRET_ACCESS_KEY" \
    --build-arg "AWS_SESSION_TOKEN" \
    -t hybris-builder \
    -t "$BUILDER_IMAGE" \
    -f builder.Dockerfile \
    .
elif [ "$TARGET" = "runner" ]; then
  docker build \
    --build-arg "BUILDER_IMAGE=$BUILDER_IMAGE" \
    -t hybris-runner \
    -t "$RUNNER_IMAGE" \
    -f runner.Dockerfile \
    .
else
  echo "Usage: ./build.sh <builder | runner>"
  exit 1
fi
