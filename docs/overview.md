
# Protect Docker Tools Overview

This repo contains [Docker Compose](https://docs.docker.com/compose/) stacks for various parts of the NS8 Protect stack. Depending on what you're working on, different stacks can be composed together by passing the `docker-compose.yml` file for the components you want to run to `docker-compose`.  For example, the [compose-all](../protect-client/compose-all.sh) script will compose together the `docker-compose.yml` for the client, along with the pieces necessary to run the protect API in a `docker-compose` stack. For common combinations (e.g., `protect-client` along with `protect-api`), stacks in this repo should include `./compose[-parts].sh` scripts for convenience.

Configuration for the stacks is generally done with `.env` files.  When composing stacks, the `.env` file must contain all variables for all parts of the stack being composed. E.g., for `magento/compose-all.sh`, the `.env` file must contain all the variables necessary for `magento`, `protect-api` and `protect-client`.

## Setup

Before using the stacks in the repo you need several tools and accounts setup; the easiest way to make sure all this has been completed is by following the [Setup - Getting Started](https://ns8.slab.com/posts/setup-getting-started-sph7gsfr) document in Slab.

### Environment

The scripts in this repo expect the various NS8 repositories to be checked out to a single directory, and the `NS8_SRC` environment variable is used to reference that directory.  To facilitate this, choose a directory and set it as the `NS8_SRC` environment variable in a file like `~/.zshrc` or `~/.bashrc` (don't forget to `source` the file after you save it):

```bash
export NS8_SRC=~/src
```

Also, all repos must be checked out to a directory that matches the repo name, e.g:

```bash
$ cd $NS8_SRC
$ git clone https://github.com/ns8inc/protect-tools-docker
```

The above command will clone the repo into `protect-tools-docker`; it has to be cloned into that exact directory, as do all the other repos referenced by these scripts, or they won't work.

#### ngrok

Services are generally exposed via `ngrok`, by starting a container running [ngrok](https://hub.docker.com/r/wernight/ngrok/) inside the `docker-compose` stack so that it has direct access to the stack's [network](https://docs.docker.com/compose/networking/#specify-custom-networks). To create these tunnels you need to set a "subdomain" for the tunnel, usually through an environment variable. Before setting the values, you may want to reserve the subdomain, just to ensure you don't run into issues starting the `ngrok` containers due to the specified subdomain being in use.

To Reserve an `ngrok` subdomain:

- Log into the [ngrok dashboard](https://dashboard.ngrok.com/login).
- Go to the [Domains](https://dashboard.ngrok.com/endpoints/domains) page.
- Click `+ Reserve a Domain`.
- Enter a name and description for the domain. An example name pattern is:
    ```
    firstnamelastname-protect-api
    ```
- Click `Reserve`.

Also, it may be helpful to export an `NGROK_AUTH` environment variable (obtained from ngrok's [Your Authtoken](https://dashboard.ngrok.com/auth/your-authtoken) page) the same way you export `NS8_SRC`, just to avoid needing to copy the value into *N* different `.env` files.

## `docker-compose` from 10,000'

Not trying to reproduce [the documentation](https://docs.docker.com/compose/reference/overview/) here, just give a very quick overview.

1. `docker-compose up -d`

Start all services (containers) in the stack.  If some of them are already running, that's fine, it will just start any that have died.

1. `docker-compose stop`

Stop all services (containers) in the stack.  Think of this as just killing off the processes; the containers themselves are left in-place and can be started quickly with `docker-compose up`.

1. `docker-compose down`

Remove all services (containers) in the stack. This removes the containers, so any ephemeral data that is not kept in a `volume` will be destroyed. To delete volumes as well, pass the `-v` option.

1. `docker-compose logs [-f] <service-name>`

Print all logs (stdout) from the associated service.

1. `docker-compose exec <service-name> <command>`

Run `<command>` inside the `<service-name>` container.  For example, to start a shell inside the container for `protect-api`, you'd run something like `./compose.sh exec protect-api /bin/bash`.
