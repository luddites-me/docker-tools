## Overview

The `protect-api` directory contains a `docker-compose` stack to enable docker-based testing and debugging for the [Protect API](https://github.com/luddites-me/luddites-api).

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

This container will run the protect API along with `mysql` or `postgres` and `dynamodb`. The configuration for the `protect-api` is primarily in `$LUDDITES_SRC/luddites-api/config/${APP_ENV}.yml`, *just like when you're running it locally, outside of docker*, but the [`start-api` script](../protect-api/build-context/start-api.sh) will override certain settings to what they should be for this environment.

### AWS Profile

The `docker-compose.yml` file maps `~/.aws` into the container, and sets `AWS_PROFILE=current_profile`.  This makes it easy to work with the [aws-mfa ohmyzsh plugin](https://github.com/joepjoosten/aws-cli-mfa-oh-my-zsh), but it doesn't require that; as long as `current_profile` is a valid profile name with keys that provide the access the protect API needs, things should work.  If you are using the plugin, just run `aws-mfa luddites-development` in a shell before running `./compose-all.sh up -d`, and you're good to go.  When the tokens timeout, you'll need to authenticate again and restart the API (`./compose-all.sh restart protect-api`); there's a script called [`./update-mfa-and-restart-api.sh`](../update-mfa-and-restart-api.sh) that does this for convenience (just make sure the `aws-get-creds` script from that plugin is in your path).

### Getting the source

```bash
$ cd $LUDDITES_SRC
$ git clone https://github.com/luddites-me/luddites-api
```

### Configuration

See [Composing Services](./overview.md#Composing Services) for a general overview of how to configure the protect-api service. The values in `.env.defaults` cover everything needed to get started, so nothing needs to be set in the common case.

 1. `APP_ENV`
  - default: `dev`
  - must be set to `dev` currently, otherwise dev/test seed data migrations will not run (see implementation of `MigrationEnvironment` decorator in `luddites-api`)
 2. `NO_DEBUG`
  - default: '' (empty)
  - if non-empty, the start script runs the compiled output without nodemon, ts-node or debugging enabled. This may be desired if you're not actively developing `protect-api`, since it could increase perf
 3. `PROTECT_API_COMPOSE_MYSQL`
  - default: ✅
  - if non-empty, include [`mysql`](../common/docker-compose.database.mysql.yml) in the stack
 4. `PROTECT_API_COMPOSE_POSTGRES`
  - default: '' (empty)
  - if non-empty, check that [`postgres`](../postgres) is in the stack (i.e., `COMPOSE_POSTGRES` is defined)

    If this is non-empty, the `start-api` script will set the `dbConnection.type` to `postgres`, and also set the values from `POSTGRES_USERNAME` and `POSTGRES_PASSWORD`.
 5. `PROTECT_API_NO_CONFIG_OVERRIDES`
  - default: '' (empty)
  - if non-empty, the `start-api` script will not override any settings in `config/${APP_ENV}.yml`, so all values must be set manually
 6. `PROTECT_API_SUBDOMAIN`
  - default: ${NGROK_SUBDOMAIN_PREFIX}-protect-api
  - the subdomain used used by ngrok to make the protect api accessible (you may want to [reserve](./overview.md#ngrok) ahead of time)
 7. `PROTECT_API_URL`
  - default: https://${PROTECT_API_SUBDOMAIN}.ngrok.io/
  - this is used to override `ludditesApiHost` in `config/${APP_ENV}.yml`, and may also be referenced by other services when they're composed with `protect-api`.
 8. `PROTECT_CLIENT_URL`
  - default: none
  - if non-empty, this is used to override `ludditesFrontEndUrl` in `config/${APP_ENV}.yml`. If composing with `protect-client`, this will be set by that service by default
 9. `TEMPLATE_SERVICE_URL`
  - default: none
  - if non-empty, this is used to override `ludditesTemplateHostUrl` in `config/${APP_ENV}.yml`. If composing with `template-service`, this will be set by that service by default
 10. `V1_API_SERVICE_URL`
  - default: https://${V1_API_SERVICE_SUBDOMAIN}.ngrok.io/
  - this will override the ``v1Proxy.baseUrl`` url in `config/${APP_ENV}.yml`

## Development

### Services

The main service is `protect-api`:

```bash
$ cd $LUDDITES_SRC/docker-tools
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

In case any `.ts` file in `luddites-api/src` is changed, `nodemon` should restart the protect api.

You can run `mocha` inside the container:

```bash
$ cd $LUDDITES_SRC/docker-tools
$ ./compose.sh up -d
# Get a shell inside the container:
$ ./compose.sh exec protect-api /bin/bash
(container shell) $ cd luddites-api
(container shell) $ yarn test
```
