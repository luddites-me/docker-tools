# Magento Docker Setup

This is a work-in-progress effort to enable docker-based development for the
Magento integration. Before going through this setup, make sure you've completed
the [Setup - Getting Started](https://ns8.slab.com/posts/setup-getting-started-sph7gsfr)
document in Slab. At a minimum you should have the Protect API and Client set
up and running locally, including their ngrok tunnels.

## Table of Contents

- [Introduction](#introduction)
- [Setup](#setup)
- [General Information](#general-information)
  - [Push new version](#push-new-version)
  - [Updating environment](#updating-environment)
  - [Debugging](#debugging)
  - [Getting a shell](#getting-a-shell)
- [TODO](#todo)

## Introduction

This setup uses [Docker Compose](https://docs.docker.com/compose/) to define and
run a multi-container Docker application. The services that make up our
multi-container app are defined in [docker-compose.yml](../magento/docker-compose.yml).
As you can see in that file, Docker Compose will set up containers for dynamodb,
mysql, magento, and ngrok-magento.

As with any Docker application, the environment for our application is defined
in our [Dockerfile](../magento/Dockerfile).

## Setup

1. Reserve an ngrok domain for your magento docker:
    - Log into the [ngrok dashboard](https://dashboard.ngrok.com/login).
    - Go to the [Domains](https://dashboard.ngrok.com/endpoints/domains) page.
    - Click `+ Reserve a Domain`.
    - Enter a name and description for the domain. An example name pattern is:
        ```
        firstnamelastname-local-magento
        ```
    - Click `Reserve`.

1. This setup contains scripts that expect various repositories to be in the
same parent directory. To facilitate this, choose a directory and set it as the
`NS8_SRC` environment variable in a file like `~/.zshrc` or `~/.bashrc` (don't
forget to `source` the file after you save it):
    ```
    export NS8_SRC=~/ns8
    ```
1. Clone the required repositories to your `$NS8_SRC` directory:
    ```
    cd $NS8_SRC
    git clone https://github.com/ns8inc/protect-integration-magento
    git clone https://github.com/ns8inc/protect-switchboard-magento
    git clone https://github.com/ns8inc/protect-tools-docker
    ```
1. Create the `.env` file that will contain your mageno environment variables:
    ```
    cd ${NS8_SRC}/protect-tools-docker/magento
    cp .env.defaults .env
    ```
1. Open the `.env` file in a text editor and set the following environment variables:
    - `NS8_SRC` - same value as above
    - `NGROK_AUTH` - obtained from ngrok's [Your Authtoken](https://dashboard.ngrok.com/auth/your-authtoken) page
    - `MAGENTO_NGROK_SUBDOMAIN` - ngrok domain you reserved in step 1
    - `PROTECT_API_SUBDOMAIN` - ngrok domain for your protect api
    - `PROTECT_CLIENT_SUBDOMAIN` - ngrok domain for your protect client
1. Increase the resources available to Docker:
    - Open Docker Desktop's preferences.
    - Go to `Resources`.
    - Increase the `CPUs`, `Memory`, and `Swap` to appropriate values for your machine.
    - Click `Apply & Restart`.
1. Start the containers (from the `${NS8_SRC}/protect-tools-docker/magento/` directory).
Note that the first run can take a while:
    ```
    docker-compose up
    ```
1. Start the Protect API and its ngrok tunnel in separate terminals:
    ```
    yarn start:dev
    ngrok http -subdomain={your-api-subdomain} --host-header=rewrite 8080
    ```
1. Start the Protect Client and its ngrok tunnel in separate terminals:
    ```
    yarn local-full-build
    ngrok http -subdomain={your-client-subdomain} --host-header=rewrite 4000
    ```
1. Create the `.env` file that will contain your magento switchboard environment
variables:
    ```
    cd ${NS8_SRC}/protect-switchboard-magento
    cp .env.defaults .env
    ```
1. Open the `.env` file in a text editor and set the `DEV_SUFFIX` environment
variable. Its value should match the value you set for `DEV_NAME` in your
Protect API `.env` file.
1. Build and deploy magento switchboard:
    ```
    yarn build
    yarn deploy
    ```
1. Log into Magento as the admin:
    - Navigate to your Magento ngrok URL, appending `index.php/admin_demo`. It should look something like this:
        ```
        https://{your-magento-subdomain}.ngrok.io/index.php/admin_demo
        ```
    - Use the `--admin-user` and `--admin-password` credentials found in
    [magento/setup-magento.sh](../magento/setup-magento.sh)

## General Information

### Push new version

```bash
docker-compose build
docker tag "${COMPOSE_PROJECT_NAME}_magento:latest" "${IMAGE}:latest"
docker push "${IMAGE}:latest"
```

### Updating environment

Updating `MAGENTO_BASE_URL`, `PROTECT_API_URL` or `PROTECT_CLIENT_URL` in `.env`
and then running `docker-compose up` will cause docker-compose to recreate the
container (these are the variables referenced in `docker-compose.yml`). If the
container is recreated, it will reinstall magento and protect. Since the
database volume is persistent, the install will be much faster the second time
around, but you need to set `SKIP_CREATE_MAGENTO_DB=1` or the install process
will fail (since the database already exists).

### Debugging

To enable `Xdebug`, you need to define the `XDEBUG_CONFIG` environment variable.
`Xdebug` needs to know the address of the docker host in order to connect; if you're
running on linux, you can get the IP with `docker network inspect`:

```bash
cd "${NS8_SRC}/protect-tools-docker/magento"
source .env # loads COMPOSE_PROJECT_NAME
docker-compose stop magento # stop the instance so that it will see the new ENV values
DEBUG_IP=$(docker network inspect "${COMPOSE_PROJECT_NAME}_protect" \
| jq -r '.[0].IPAM.Config[0].Gateway')
echo "XDEBUG_CONFIG=\"remote_enable=1 remote_host=${DEBUG_IP}\"" >> .env
docker-compose up -d
```

If you're running `docker desktop`, the IP address returned from `docker network
inspect` above will be the address of the linux VM where docker's running, not
the IP that the PHP debugger listens on.  In that case, it's easiest to just set
the `XDEBUG_CONFIG="remote_enable=1 remote_host=<YOUR IP>"` value manually in
your `.env` file.

### Getting a shell

To get a shell matching the `USER` set in the `Dockerfile`:

```bash
cd "${NS8_SRC}/protect-integration-magento/docker" $ docker-compose exec
magento /bin/bash
```

For root:

```bash
docker-compose exec --user root magento /bin/bash
```

## TODO

1. Use better tags for pushing new versions.
1. Investigate `docker-compose.overrides.yml` (or similar) to compose with
protect-api and client/middleware.
1. VS Code `.devcontainer` can work well with remote docker hosts via SSH, and
would give better support for non-PHP codebases.
1. Use `k8s`/`minicube` instead of `docker-compose`?
