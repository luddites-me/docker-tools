## Overview

The `v1-api-service` directory contains a `docker-compose` stack to enable docker-based testing and debugging (coming soon) for the [V1 API](https://github.com/ns8inc/ns8-api-host).

## tl;dr

1. Become famililar with the stuff in this repo. (especally NS8_SRC, dir structure and other env variables)
1. Checkout the code from here: `https://github.com/ns8inc/ns8-api-host` into here: `$NS8_SRC/`
1. Go to dir `$NS8_SRC/protect-tools-docker`
1. Set `COMPOSE_V1_API_SERVICE` to `true` in a newly created or existing `.env`
1. Make sure you have set `NGROK_SUBDOMAIN_PREFIX` (suggestions: `<your-first-initial><your-last-name>-local`) in the .env file
1. Run `./compose-all.sh up -d`

1. optionally watch the logs with `./compose-all.sh logs -f v1-api-service`
1. Go have a look at the [ngrok inspector](http://localhost:40405)

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

This container will run the V1 API along with a local `mongodb` if set. This docker compose guide does not (yet) go through setting it up to run using the test mongodb cluster in aws using ssh, for that see the readme in the [ns8-api-host github repo](https://github.com/ns8inc/ns8-api-host/readme.md).

This docker compose will start up a local instance of mongodb and add a set of all "fake" credentials into the `administration` database, in the `options` collection, as the v1-api expects to find at startup. This is only run once on first start of the mongoDB container, so to change later, would need to manually update in mongo directly or remove the mongodatadb volume.

## Known issues

The v1 api requires access to minFraud to score an order. This could be worked around by using the mongodb test cluster via ssh, or setting the minFraud apiKey in the `administration.options` encrypted collection.

If testing the local instance on an actual storefront where scoring is needed via the truestats script, follow the instructions on the [ns8-api-host readme](https://github.com/ns8inc/ns8-api-host/readme.md) section under `/web/push` to change the values of `cdnScriptHost` and `processorHost` in the `settings.ts` file, to the value of the ngrok (or other) access method to your local env.

### Getting the source

```bash
$ cd $NS8_SRC
$ git clone https://github.com/ns8inc/ns8-api-host
```

### Configuration

See [Composing Services](./overview.md#Composing Services) for a general overview of how to configure the service. The values in `.env.defaults` cover everything needed to get started, so nothing needs to be set in the common case.

 1. `V1_API_SERVICE_MONGODB`
  - default: 'true'
  - if non-empty, include [`monogdb`](https://hub.docker.com/_/mongo) in the stack. If empty, do not include mongodb in the stack.
 2. `V1_API_SERVICE_SUBDOMAIN`
  - default: ${NGROK_SUBDOMAIN_PREFIX}-v1-api
  - the subdomain used used by ngrok to make the v1 api accessible
 3. `V1_API_SERVICE_URL`
  - default: https://${V1_API_SERVICE_SUBDOMAIN}.ngrok.io/
  - this is referenced by other services such as `protect-api`.

### Services

The main service is `v1-api-service`:

```bash
$ cd $NS8_SRC/protect-tools-docker
$ # Start all services/containers in the stack:
$ ./compose-all.sh up -d
# Follow the logs from the v1 service:
$ ./compose-all.sh logs -f v1-api-service
```

The `ngrok` UI for `v1-api-service` is available at https://localhost:40405.

The port for `mongodb:27017` is bound to the host, so you can connect to the instance from the host on `localhost:27017`.

The v1-api-service is bound to local port 3333, for access: `localhost:3333`.

### Debugging

Not yet implemented.
