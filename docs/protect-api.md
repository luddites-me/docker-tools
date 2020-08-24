## Overview

The `protect-api` directory contains a `docker-compose` stack to enable docker-based testing and debugging for the [Protect API](https://github.com/ns8inc/ns8-protect-api).

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

This container will run the protect API along with `mysql` or `postgres` and `dynamodb`. The configuration for the `protect-api` is primarily in `$NS8_SRC/ns8-protect-api/config/${APP_ENV}.yml`, *just like when you're running it locally, outside of docker*, but the [`start-api` script](../protect-api/build-context/start-api.sh) will override certain settings to what they should be for this environment.

### Getting the source

```bash
$ cd $NS8_SRC
$ git clone https://github.com/ns8inc/ns8-protect-api
```

### Configuration

See [Composing Services](./overview.md#Composing Services) for a general overview of how to configure the protect-api service. The values in `.env.defaults` cover everything needed to get started, so nothing needs to be set in the common case.

 1. `APP_ENV`
  - default: `dev`
  - must be set to `dev` currently, otherwise dev/test seed data migrations will not run (see implementation of `MigrationEnvironment` decorator in `ns8-protect-api`)
 2. `NO_DEBUG`
  - default: '' (empty)
  - if non-empty, the start script runs the compiled output without nodemon, ts-node or debugging enabled. This may be desired if you're not actively developing `protect-api`, since it could increase perf
 3. `PROTECT_API_COMPOSE_MYSQL`
  - default: ✅
  - if non-empty, include [`mysql`](../common/docker-compose.database.mysql.yml) in the stack
 4. `PROTECT_API_COMPOSE_POSTGRES`
  - default: '' (empty)
  - if non-empty, include [`postgres`](../common/docker-compose.database.postgres.yml) in the stack

    If this is non-empty, the `start-api` script will set the `dbConnection.type` to `postgres`, and also set the values from `POSTGRES_USERNAME` and `POSTGRES_PASSWORD`.
 5. `PROTECT_API_COMPOSE_PGADMIN`
  - default: '' (empty)
  - if non-empty, include [`pgAdmin`](https://www.pgadmin.org/) in the stack; probably only useful/desired if `PROTECT_API_COMPOSE_POSTGRES` is also set
 6. `PROTECT_API_NO_CONFIG_OVERRIDES`
  - default: '' (empty)
  - if non-empty, the `start-api` script will not override any settings in `config/${APP_ENV}.yml`, so all values must be set manually
 7. `PROTECT_API_SUBDOMAIN`
  - default: ${NGROK_SUBDOMAIN_PREFIX}-protect-api
  - the subdomain used used by ngrok to make the protect api accessible (you may want to [reserve](./overview.md#ngrok) ahead of time)
 8. `PROTECT_API_URL`
  - default: https://${PROTECT_API_SUBDOMAIN}.ngrok.io/
  - this is used to override `ns8ApiHost` in `config/${APP_ENV}.yml`, and may also be referenced by other services when they're composed with `protect-api`.
 9. `PROTECT_CLIENT_URL`
  - default: none
  - if non-empty, this is used to override `ns8FrontEndUrl` in `config/${APP_ENV}.yml`. If composing with `protect-client`, this will be set by that service by default
 10. `TEMPLATE_SERVICE_URL`
  - default: none
  - if non-empty, this is used to override `ns8TemplateHostUrl` in `config/${APP_ENV}.yml`. If composing with `template-service`, this will be set by that service by default
 11. `V1_API_SERVICE_URL`
  - default: https://${V1_API_SERVICE_SUBDOMAIN}.ngrok.io/
  - this will override the ``v1Proxy.baseUrl`` url in `config/${APP_ENV}.yml`

## Development

### Services

The main service is `protect-api`:

```bash
$ cd $NS8_SRC/protect-tools-docker
$ # Start all services/containers in the stack:
$ ./compose-all.sh up -d
# Follow the logs from the protect API:
$ ./compose-all.sh logs -f protect-api
```

The `ngrok` UI for `protect-api` is available at https://localhost:40401.

The ports for `mysql:3306` and `dynamodb:8000` are bound to the host, so you can connect to the mysql instance from the host on `localhost:3306`.

The `node` debugger for `protect-api` is bound to the host at port `9229`.

### Debugging

There's a `vs code` debug configuration in this project that can be used to connect attach to the protect api.

In case any `.ts` file in `ns8-protect-api/src` is changed, `nodemon` should restart the protect api.

You can run `mocha` inside the container:

```bash
$ cd $NS8_SRC/protect-tools-docker
$ ./compose.sh up -d
# Get a shell inside the container:
$ ./compose.sh exec protect-api /bin/bash
(container shell) $ cd ns8-protect-api
(container shell) $ yarn test
```
