#!/usr/bin/env bash

set -o errexit

SCRIPTDIR="$(dirname "$0")"

declare -A VAR_NAME_TO_STACK_DIR_MAP
VAR_NAME_TO_STACK_DIR_MAP[COMPOSE_POSTGRES]="$(realpath "${SCRIPTDIR}/postgres")"
VAR_NAME_TO_STACK_DIR_MAP[COMPOSE_PROTECT_API]="$(realpath "${SCRIPTDIR}/protect-api")"
VAR_NAME_TO_STACK_DIR_MAP[COMPOSE_PROTECT_CLIENT]="$(realpath "${SCRIPTDIR}/protect-client")"
VAR_NAME_TO_STACK_DIR_MAP[COMPOSE_TEMPLATE_SERVICE]="$(realpath "${SCRIPTDIR}/template-service")"
VAR_NAME_TO_STACK_DIR_MAP[COMPOSE_V1_API_SERVICE]="$(realpath "${SCRIPTDIR}/v1-api-service")"

echo-err () {
  echo "ERROR: " "$@" 1>&2
}

echo-dbg () {
  if [ -n "${DEBUG}" ]; then
    echo "$@" 1>&2
  fi
}

get-services () {
  local SERVICE_DIR
  local GET_SERVICES_SCRIPT
  SERVICE_DIR=$1
  GET_SERVICES_SCRIPT="${SERVICE_DIR}/get-compose-services.sh"
  if [ ! -e "${GET_SERVICES_SCRIPT}" ]; then
    echo-err "Script not found: ${GET_SERVICES_SCRIPT}"
    return 1;
  fi

  "${GET_SERVICES_SCRIPT}"
}

contains-element () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

ROOT_ENV="$(node "${SCRIPTDIR}/load-env-check-schema.js")"
declare -a ENV_SCHEMA_DIRS
for COMPOSE_FLAG in "${!VAR_NAME_TO_STACK_DIR_MAP[@]}"; do
  eval "$(echo "${ROOT_ENV}" | grep "${COMPOSE_FLAG}")"
  if [ -n "${!COMPOSE_FLAG}" ]; then
    STACK_DIR="${VAR_NAME_TO_STACK_DIR_MAP["${COMPOSE_FLAG}"]}"
    echo-dbg "Checking schema and loading default values from ${STACK_DIR}"
    ENV_SCHEMA_DIRS+=("--schemaDir=${STACK_DIR}")
  fi
done

eval "$(node "${SCRIPTDIR}/load-env-check-schema.js" "${ENV_SCHEMA_DIRS[@]}")"

declare -a COMPOSE_ARGS
for COMPOSE_FLAG in "${!VAR_NAME_TO_STACK_DIR_MAP[@]}"; do
  if [ -n "${!COMPOSE_FLAG}" ]; then
    STACK_DIR="${VAR_NAME_TO_STACK_DIR_MAP["${COMPOSE_FLAG}"]}"
    echo-dbg "Loading services for ${COMPOSE_FLAG#COMPOSE_} (${STACK_DIR})"
    SERVICE_COMPOSE_FILENAMES="$(get-services "${STACK_DIR}")"
    for COMPOSE_FN in ${SERVICE_COMPOSE_FILENAMES[*]}; do
      if ! contains-element "${COMPOSE_FN}" "${COMPOSE_ARGS[@]}"; then
        COMPOSE_ARGS+=("-f" "${COMPOSE_FN}")
      fi
    done
  fi
done

if [ -z "${COMPOSE_ARGS[0]}" ]; then
  echo-err "Must set at least 1 of ${!VAR_NAME_TO_STACK_DIR_MAP[*]}"
  exit 1
fi

docker-compose "${COMPOSE_ARGS[@]}" "$@"
