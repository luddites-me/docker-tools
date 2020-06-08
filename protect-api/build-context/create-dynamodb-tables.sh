#!/bin/bash

set -e

if [ -z "${APP_ENV}" ] \
  || [ -z "${DYNAMODB_ENDPOINT_URL}" ]; then
  echo "Must define APP_ENV and DYNAMODB_ENDPOINT_URL"
  exit 1
fi

table_exists () {
  aws dynamodb describe-table \
    --table-name "$1" \
    --endpoint-url "${DYNAMODB_ENDPOINT_URL}" > /dev/null 2>&1
}

if ! table_exists "ExtensionData-${APP_ENV}"; then
  echo "Creating dynamodb table ExtensionData-${APP_ENV}"
  aws dynamodb create-table \
    --table-name "ExtensionData-${APP_ENV}" \
    --attribute-definitions AttributeName=extensionId+merchantId,AttributeType=S AttributeName=objectType+objectId,AttributeType=S \
    --key-schema AttributeName=extensionId+merchantId,KeyType=HASH AttributeName=objectType+objectId,KeyType=RANGE \
    --endpoint-url "${DYNAMODB_ENDPOINT_URL}" \
    --billing-mode PAY_PER_REQUEST
  aws dynamodb wait table-exists \
    --table-name "ExtensionData-${APP_ENV}" \
    --endpoint-url "${DYNAMODB_ENDPOINT_URL}"
fi

if ! table_exists "ExtensionDefinitions-${APP_ENV}"; then
  echo "Creating dynamodb table ExtensionDefinitions-${APP_ENV}"
  aws dynamodb create-table \
    --table-name "ExtensionDefinitions-${APP_ENV}" \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --endpoint-url "${DYNAMODB_ENDPOINT_URL}" \
    --billing-mode PAY_PER_REQUEST
  aws dynamodb wait table-exists \
    --table-name "ExtensionDefinitions-${APP_ENV}" \
    --endpoint-url "${DYNAMODB_ENDPOINT_URL}"
fi
