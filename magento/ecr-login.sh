#!/bin/bash

set -e

source "$(dirname "$0")/.env"

if [ -z "${ECR_ACCOUNTID}" ] \
  || [ -z "${ECR_REGION}" ] \
  || [ -z "${COMPOSE_PROJECT_NAME}" ]; then
  echo "Must define ECR_ACCOUNTID, ECR_REGION and COMPOSE_PROJECT_NAME"
  exit 1
fi

REPO="${ECR_ACCOUNTID}.dkr.ecr.${ECR_REGION}.amazonaws.com"
IMAGE="${REPO}/${COMPOSE_PROJECT_NAME}"

aws ecr get-login-password --region "${ECR_REGION}" | \
  docker login --username AWS --password-stdin "${IMAGE}"
