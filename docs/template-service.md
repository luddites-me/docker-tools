## Overview

The `template-service` directory contains a `docker-compose` stack to enable docker-based testing and debugging for the [tempalte service](https://github.com/ns8inc/ns8-template-service).

Running the `template-service` alone is not very useful; you probably want to run it with the protect client and API using `protect-client/compose-all.sh`.

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

Also see the [template service overview](https://ns8.slab.com/posts/template-service-wvw7lxi8).

The endpoint for the `protect-api` is set in the `.env` file at `$NS8_SRC/ns8-template-service/.env`, *just like when you're running it locally, outside of docker*. The value should match what you set for `V2_API_BASE` in `$NS8_SRC/ns8-protect-client/middleware/.env` (see `$NS8_SRC/ns8-template-service/src/app/config.ts` for details).

To make the `protect-api` target the `template-service` from this stack, you need to set `ns8TemplateHostUrl` in `$NS8_SRC/ns8-protect-api/config/${APP_ENV}.yml` to `!url https://${TEMPLATE_SERVICE_SUBDOMAIN}.ngrok.io/` (substituting in the variable *value*, e.g. `!url https://ns8-firstname-lastname-template-service.ngrok.io/`).

### Getting the source

```bash
$ cd $NS8_SRC
$ git clone https://github.com/ns8inc/ns8-template-service
```

### Environment Vars

```bash
$ cd $NS8_SRC/protect-tools-docker/template-service
$ cp .env.defaults .env
$ # edit the `.env` file to set the environment variables; e.g. with vs code:
$ code .env
```

 1. [General Variables](./overview.md#Environment)
 2. URLs
   - `TEMPLATE_SERVICE_SUBDOMAIN`: The subdomain used used by ngrok to make the template service accessible (you may want to [reserve](./overview.md#ngrok) ahead of time).
   - `PROTECT_API_SUBDOMAIN`

## Development

### Services

The main service is `template-service`:

```bash
$ cd $NS8_SRC/protect-tools-docker/template-service
$ # Start all services/containers in the stack:
$ ./compose.sh up -d
# Follow the logs from the template-service:
$ ./compose.sh logs -f template-service
```

The `ngrok` UI for `template-service` is available at https://localhost:40402.

### Debugging

TODO: add a `vs code` debug configuration in this project that can be used to attach the debugger.  Currently, the `yarn dev` command that's used to launch the service in [start-template-service.sh](template-service/build-context/start-template-service.sh) doesn't include the `--inspect=9228` argument, so debugging is not available.
