## Overview

The `protect-api` directory contains a `docker-compose` stack to enable docker-based testing and debugging for the [Protect API](https://github.com/ns8inc/ns8-protect-api).

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

This container will run the protect API along with `mysql` and `dynamodb`. The configuration for the `protect-api` is primarily in `$NS8_SRC/ns8-protect-api/.env` and `$NS8_SRC/ns8-protect-api/config/${APP_ENV}.yml`, *just like when you're running it locally, outside of docker*.

Since the protect API won't run without its database dependencies, you can't just run `docker-compose`; instead use `compose.sh`.

### Getting the source

```bash
$ cd $NS8_SRC
$ git clone https://github.com/ns8inc/ns8-protect-api
```

### Environment Vars

```bash
$ cd $NS8_SRC/protect-tools-docker/protect-api
$ cp .env.defaults .env
$ # edit the `.env` file to set the environment variables; e.g. with vs code:
$ code .env
```

 1. [General Variables](./overview.md#Environment)
 2. URLs
   - `PROTECT_API_SUBDOMAIN`: The subdomain used used by ngrok to make the protect api accessible (you may want to [reserve](./overview.md#ngrok) ahead of time).
 3. `APP_ENV`: must be set to `dev`

### configuration

In `$NS8_SRC/ns8-protect-api/.env` you should set `APP_ENV=dev`, and if you're deploying switchboards set the `DEV_NAME` variable appropriately.

Inside `$NS8_SRC/ns8-protect-api/config/dev.yml`, set `mySqlDatabase.host: mysql` (this is to match the "service name" inside the compose stack) and `dynamoEndpoint: !url http://dynamodb:8000/`.

## Development

### Services

The main service is `protect-api`:

```bash
$ cd $NS8_SRC/protect-tools-docker/protect-api
$ # Start all services/containers in the stack:
$ ./compose.sh up -d
# Follow the logs from the protect API:
$ ./compose.sh log -f protect-api
```

The `ngrok` UI for `protect-api` is available at https://localhost:40401.

The ports for `mysql:3306` and `dynamodb:8000` are bound to the host, so you can connect to the mysql instance from the host on `localhost:3306`.

The `node` debugger for `protect-api` is bound to the host at port `49228`.

### Debugging

There's a `vs code` debug configuration in this project that can be used to connect attach to the protect api.

In case any `.ts` file in `ns8-protect-api/src` is changed, `nodemon` should restart the protect api.

You can run `mocha` inside the container:

```bash
$ cd $NS8_SRC/protect-tools-docker/protect-api
$ ./compose.sh up -d
# Get a shell inside the container:
$ ./compose.sh exec protect-api /bin/bash
(container shell) $ yarn test
```
