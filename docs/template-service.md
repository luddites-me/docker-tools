## Overview

The `template-service` directory contains a `docker-compose` stack to enable docker-based testing and debugging for the [tempalte service](https://github.com/ns8inc/ns8-template-service).

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

Also see the [template service overview](https://ns8.slab.com/posts/template-service-wvw7lxi8).

If `PROTECT_API_URL` is defined (as it is automatically when composing with `protect-api`), the [`tart-template-service` script](../template-service/build-context/start-template-service.sh) will set `V2_API_BASE` appropriately before starting the service.

Whten this service is composed with `protect-api`, it will define `TEMPLATE_SERVICE_URL` and `protect-api` will use that value for `ns8TemplateHostUrl` by default.

### Getting the source

```bash
$ cd $NS8_SRC
$ git clone https://github.com/ns8inc/ns8-template-service
```

### Configuration

See [Composing Services](./overview.md#Composing Services) for a general overview of how to configure the protect-client service. The values in `.env.defaults` cover everything needed to get started, so nothing needs to be set in the common case.

 1. [General Variables](./overview.md#Environment)
 2. `TEMPLATE_SERVICE_SUBDOMAIN`
  - default: ${NGROK_SUBDOMAIN_PREFIX}-template-service
  - the subdomain used used by ngrok to make the template service accessible (you may want to [reserve](./overview.md#ngrok) ahead of time)
 3. `TEMPLATE_SERVICE_URL`
  - default: https://${TEMPLATE_SERVICE_SUBDOMAIN}.ngrok.io/
  - this may be referenced by other services when they're composed with `template-service`.

## Development

### Services

The main service is `template-service`:

```bash
$ cd $NS8_SRC/protect-tools-docker
$ # Start all services/containers in the stack:
$ ./compose.sh up -d
# Follow the logs from the template-service:
$ ./compose.sh logs -f template-service
```

The `ngrok` UI for `template-service` is available at https://localhost:40402.

### Debugging

TODO: add a `vs code` debug configuration in this project that can be used to attach the debugger.  Currently, the `yarn dev` command that's used to launch the service in [start-template-service.sh](template-service/build-context/start-template-service.sh) doesn't include the `--inspect=9228` argument, so debugging is not available.
