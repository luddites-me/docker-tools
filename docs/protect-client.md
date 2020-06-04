## Overview

The `protect-client` directory contains a `docker-compose` stack to enable docker-based testing and debugging for the [Protect client](https://github.com/ns8inc/ns8-protect-client).

If you want to run the protect API *and* client in the stack, first [setup the `protect-api` stack](./protect-api.md).

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

This container will run both the middleware and the webpack dev server for the client.  The endpoint for the `protect-api` is set in the `.env` file at `$NS8_SRC/ns8-protect-client/middleware/.env`, *just like when you're running it locally, outside of docker*.

If you run just `docker-compose`, only the client service is started. To compose with `protect-api` and `template-service`, use `compose-all.sh`.

### Getting the source

```bash
$ cd $NS8_SRC
$ git clone https://github.com/ns8inc/ns8-protect-client
```

### Environment Vars

```bash
$ cd $NS8_SRC/protect-tools-docker/protect-client
$ cp .env.defaults .env
$ # edit the `.env` file to set the environment variables; e.g. with vs code:
$ code .env
```

 1. [General Variables](./overview.md#Environment)
 2. URLs
   - `PROTECT_CLIENT_SUBDOMAIN`: The subdomain used used by ngrok to make the protect client accessible (you may want to [reserve](./overview.md#ngrok) ahead of time).

## Development

### Services

The main service is `protect-client`:

```bash
$ cd $NS8_SRC/protect-tools-docker/protect-client
$ # Start all services/containers in the stack:
$ ./compose-all.sh up -d
# Follow the logs from the middleware and webpack dev server:
$ ./compose-all.sh logs -f protect-client
```

The `ngrok` UI for `protect-client` is available at https://localhost:40400.

### Debugging

There's a `vs code` debug configuration in this project that can be used to launch Chrome and attach the debugger.

The webpack dev server should hot reload any changes made to `ns8-protect-client/client`, and `nodemon` should restart the middleware server in case changes are made to `ns8-protect-client/middleware`.
