
# Protect Docker Tools Overview

This repo contains [Docker Compose](https://docs.docker.com/compose/) stacks for various parts of the NS8 Protect stack.

## Setup

Before using the stacks in the repo you need several tools and accounts setup; the easiest way to make sure all this has been completed is by following the [Setup - Getting Started](https://ns8.slab.com/posts/setup-getting-started-sph7gsfr) document in Slab.

### Mac

If you're using a Mac, you'll need to install some dependencies ([Homebrew](https://brew.sh/), Bash 5.x, and coreutils):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew install bash coreutils
```

### Environment

The scripts in this repo expect the various NS8 repositories to be checked out to a single directory, and the `NS8_SRC` environment variable is used to reference that directory. Either set the path manually in the .env file, or if using the same path universally, remove the key from the .env file and set `NS8_SRC` environment variable in a file like `~/.zshrc` or `~/.bashrc` (don't forget to `source` the file after you save it):

```bash
export NS8_SRC=~/src
```

Also, all repos must be checked out to a directory that matches the repo name, e.g:

```bash
cd $NS8_SRC
git clone https://github.com/ns8inc/protect-tools-docker
```

The above command will clone the repo into `protect-tools-docker`; it has to be cloned into that exact directory, as do all the other repos referenced by these scripts, or they won't work.


### Quickstart

For developers that already have all their accounts setup and repos checked out to `$NS8_SRC`, this section should get you going quickly.

All parameters are set as environment variables; you can see the required env vars in [.env.schema](../.env.schema), and their defaults in [.env.defaults](../.env.defaults).  By default we include 3 services, as seen in `.env.defaults`:
```
COMPOSE_PROTECT_API=✅
COMPOSE_PROTECT_CLIENT=✅
COMPOSE_TEMPLATE_SERVICE=✅
```

First, run `yarn install` to get the `dotenv-expand` and `dotenv-extended` packages that we use to read the `.env` files.

If you run `./compose-all.sh up -d` and there are any required env vars missing, it will complain:

```sh
$ ./compose-all.sh up -d
~/src/protect-tools-docker/node_modules/dotenv-extended/lib/index.js:59
      throw new Error('MISSING CONFIG VALUES: ' + missingKeys.join(', '));
      ^

Error: MISSING CONFIG VALUES: NGROK_SUBDOMAIN_PREFIX
    ...
```

Set `NGROK_SUBDOMAIN_PREFIX` in `.env`, and you should be good to go:
```
$ echo 'NGROK_SUBDOMAIN_PREFIX=rockstar-dev' >> .env
$ ./compose-all.sh up -d
Creating network "protect_protect" with driver "bridge"
Creating protect_protect-client_1         ... done
Creating protect_mysql_1                  ... done
Creating protect_dynamodb_1               ... done
Creating protect_template-service_1 ... done
Creating protect_ngrok-template-service_1 ... done
Creating protect_protect-api_1            ... done
Creating protect_ngrok-protect-api_1      ... done
Creating protect_ngrok-protect-client_1   ... done
```

Now you have the protect-api, protect-client and template-service running in your stack.

#### `ngrok`

Services are generally exposed via `ngrok`, by starting a container running [ngrok](https://hub.docker.com/r/wernight/ngrok/) inside the `docker-compose` stack so that it has direct access to the stack's [network](https://docs.docker.com/compose/networking/#specify-custom-networks). To create these tunnels you need to set a "subdomain" for the tunnel, usually through an environment variable. Before setting the values, you may want to reserve the subdomain, just to ensure you don't run into issues starting the `ngrok` containers due to the specified subdomain being in use.

To Reserve an `ngrok` subdomain:

- Log into the [ngrok dashboard](https://dashboard.ngrok.com/login).
- Go to the [Domains](https://dashboard.ngrok.com/endpoints/domains) page.
- Click `+ Reserve a Domain`.
- Enter a name and description for the domain. An example name pattern is:

  ```text
  firstnamelastname-protect-api
  ```

- Click `Reserve`.

Many stacks in this repo require an `NGROK_AUTH` environment variable to be defined (obtained from ngrok's [Your Authtoken](https://dashboard.ngrok.com/auth/your-authtoken) page, or if you've already setup ngrok locally, you can retrieve your auth token from `~/.ngrok2/ngrok.yml`). Also, default values for `ngrok` subdomains are commonly built from a `NGROK_SUBDOMAIN_PREFIX` environment variable (e.g., `NGROK_SUBDOMAIN_PREFIX=ns8-devname` will result in `protect-api` being served from `https://ns8-devname-protect-api.ngrok.io` by default).

## Composing Services with `compose-all.sh`

The [`compose-all.sh`](../compose-all.sh) is used to compose multiple services in a single stack, and share configuration via environment variables across the services.  It's basically a thin wrapper around `docker-compose` that's just used to gather the `docker-compose.yml` files you want included in the stack and setup/validate environment variables.

Depending on what you're working on, different services can be composed together by setting the `COMPOSE_[SERVICE]` variable for the service you want to include, and running the `compose-all.sh` script to setup the environment and invoke `docker-compose` with the `.yml` files for the services indicated.

The way this works is to associate a `COMPOSE_[SERVICE]` variable with each service directory (e.g., `COMPOSE_PROTECT_API` is associated with [`protect-api`](../protect-api)). Each "service directory" contains a script named `get-compose-services.sh`, which prints out the names of the .yml files to be passed to `docker-compose`. Additionally, the service directory can contain an `.env.schema` file to define environment variables that must be defined (`compose-all.sh` will fail with an error message if any are not), and an `.env.defaults` file to set default values for required environment variables. If you want values in `.env` or `.env.defaults` to override any values you already have in your environment, just set a variable named `ENVFILE_TAKES_PRECEDENCE`; by default, values already set in your environment take precedence.

Some care should be taken to not set the default value for the same environment variable in multiple "services", since the order the defaults are loaded in is arbitrary, and defaults are only applied in the case there is no value previously set (either pre-existing in the environment, or within the `.env` file). This means if a variable, e.g. `PROTECT_API_URL`, is optional, it should not be set to a default value of `''` in any service, since doing so can prevent it from being set to its real value later on. Instead, just leave the optional variable out of `.env.schema`, and document what happens if it is set.

Similarly, the services defined in each `docker-compose.yml` files should be distinct. If multiple stacks want to use the same service, include a compose `.yml` file for that service in the `common` directory, and return all desired `.yml` files from the `get-compose-services.sh` script. The order the `.yml` files are passed to `docker-compose` is lexiographic, so `compose-all.sh` can't be used in cases where the order of the `.yml` files is important (i.e., where the same service is defined in multiple files).

### Multiple stacks

The `COMPOSE_PROJECT_NAME` variable is used as a prefix for all resources created by `docker-compose`, so it's an easy way maintain containers and volumes for multiple stacks separately.  E.g., you can run `./compose-all.sh down`, then update `COMPOSE_PROJECT_NAME` to some other value, and when you run `./compose-all.sh up` will create all new containers and volumes, and your older containers and data will be left intact in case you want to start them up again by setting `COMPOSE_PROJECT_NAME` back to its original value.  This makes it relatively easy to maintain stacks of different combinations by just keeping separate `.env.some-stack` files, and linking `.env` to the stack you want active.

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

Run `<command>` inside the `<service-name>` container.  For example, to start a shell inside the container for `protect-api`, you'd run something like `./compose-all.sh exec protect-api /bin/bash`.

### Composition with `docker-compose`

Overrides to the docker-compose.yaml can be configured in a non tracked file `docker-compose.override.yaml`. This will get picked up automatically along with the default `docker-compose.yaml`. It can be used for mounting additional volumes, adding environment variables and build args to existing services, or adding entirely new services. The one caveat is that the override file is completely additive, so you can't use it to remove anything from an existing compose file.

Additional overrides can be chained together with the -f flag in docker-compose, though when using -f it's important to specify _all_ files in the order they should be applied. for example if you wish to include the sdkdev override file, your command would look like: `docker-compose -f docker-compose.yaml -f docker-compose.override.yaml -f docker-compose.sdkdev.yaml up`
