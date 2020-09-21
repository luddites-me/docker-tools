## Overview

The `protect-client` directory contains a `docker-compose` stack to enable docker-based testing and debugging for the [Protect client](https://github.com/luddites-me/luddites-client).

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

This container will run both the middleware and the webpack dev server for the client.

If `PROTECT_API_URL` is defined (as it is automatically when composing with `protect-api`), the [`start-client` script](../protect-client/build-context/start-client.sh) will set `V2_API_BASE` appropriately before starting the middleware.

### Getting the source

```bash
$ cd $LUDDITES_SRC
$ git clone https://github.com/luddites-me/luddites-client
```

### Configuration

See [Composing Services](./overview.md#Composing Services) for a general overview of how to configure the protect-client service. The values in `.env.defaults` cover everything needed to get started, so nothing needs to be set in the common case.

 1. [General Variables](./overview.md#Environment)
 2. `PROTECT_CLIENT_SUBDOMAIN`
  - default: ${NGROK_SUBDOMAIN_PREFIX}-protect
  - the subdomain used used by ngrok to make the protect client accessible (you may want to [reserve](./overview.md#ngrok) ahead of time)
 3. `PROTECT_CLIENT_URL`
  - default: https://${PROTECT_CLIENT_SUBDOMAIN}.ngrok.io/
  - this may be referenced by other services when they're composed with `protect-client`.

## Development

### Services

The main service is `protect-client`:

```bash
$ cd $LUDDITES_SRC/docker-tools
$ # Start all services/containers in the stack:
$ ./compose-all.sh up -d
# Follow the logs from the middleware and webpack dev server:
$ ./compose-all.sh logs -f protect-client
```

The `ngrok` UI for `protect-client` is available at https://localhost:40400.

### Debugging

There's a `vs code` debug configuration in this project that can be used to launch Chrome and attach the debugger.

The webpack dev server should hot reload any changes made to `luddites-client/client`, and `nodemon` should restart the middleware server in case changes are made to `luddites-client/middleware`.
