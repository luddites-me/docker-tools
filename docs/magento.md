# Overview

This is a work-in-progress effort to enable docker-based development for the
Magento Integration. The docker-compose will setup containers for dynamodb,
mysql, magento, and ngrok-magento. Ngrok-magento will tunnel your local magento
instance so that it's available on the internet. You'll also need to run ngrok
for the API and client projects. The reason for using Ngrok is because the
switchboard code runs on AWS lambda, so we need to have that code accessible to
the services it uses for development.

## Table of Contents

- [Overview](#overview)
  - [Usage](#usage)
    - [Updating environment](#updating-environment)
    - [Debugging](#debugging)
    - [Getting a shell](#getting-a-shell)
  - [TODO](#todo)

## Usage

Cross-repo paths are used in various scripts; to facilitate this, you need to
set `NS8_SRC` and clone all your repositories to that directory.
The docker files are kept in
[protect-tools-docker](https://github.com/ns8inc/protect-tools-docker). You'll
need the folling repositories at a minimum:

```bash
$ export NS8_SRC=~/src # probably want this defined in `.bashrc` or similar
$ cd $NS8_SRC
$ git clone https://github.com/ns8inc/protect-integration-magento
$ git clone https://github.com/ns8inc/protect-switchboard-magento
$ git clone https://github.com/ns8inc/protect-tools-docker
```

Before you can build/run the containers, you need to set your enviroment variables:

```bash
$ cd ${NS8_SRC}/protect-tools-docker/magento
$ cp .env.defaults .env
$ code .env # Set variables appropriately
```

- Setup Ngrok:
  - From the ngrok dashboard, navigate to "Reserved" and make a reserved domain
    for the api, client, and magento (e.g. https://dev-abc-client.ngrok.io).
    - Add the sub-domains to their respective variables in your root `.env` and
      your `docker/.env`.
- Docker notes:
  - If you haven't already, you'll want to increase the amount of RAM available
    to Docker. To do this, open the docker app and click resources, then slide
    the handle to increase RAM (recommended 6 GB).
- Set the `NS8_SRC` variable to the filepath that you have
  protection-integration-magento checked out.
- Run `yarn module:config`, this will set the environment variables in the
  config.xml for magento.
- From the docker folder, run `docker-compose up` to spin up the containers.
  - Note: the first run can take a bit, that's why we increased the available
    RAM.
- API setup:
  - Follow the readme for getting the ns8-protect-api project setup.
  - If this is your first time starting the API or the DB has been wiped, make
    sure you run `create-dynamodb-tables.sh` in the scripts folder.
    - Note: if you run into issue trying to run it, make sure you give execution
      permission - `chmod +x ./create-dynamodb-tables.sh`.
  - Start the API in dev mode, `yarn start:dev`.
  - Setup tunneling with ngrok. The API listens on port 8080, so expose that
    port:
    ```bash
    ngrok http -subdomain={your-api-subdomain} 8080
    ```
- Client setup:
  - Follow the readme for getting the ns8-protect-client project setup.
  - From the project root, run `yarn local-full-build`. This will build both
    projects and then run the middleware.
  - Setup tunneling with ngrok. The client listens on port 4000, so expose that
    port:
    ```bash
    ngrok http -subdomain={your-client-subdomain} 4000.
    ```
- Switchboard setup:
  - [Refer to getting started](getting-started.md)
- Navigate to your Magento ngrok URL, appending index.php/admin_demo to the end.
  Should look something like:
  `https://{your-magento-subdomain}.ngrok.io/index.php/admin_demo`.
- From there, login using the default dev credentials found in
  [docker/setup-magento.sh](../../../../docker/setup-magento.sh). You can speed
  up the process by pulling the docker image instead of building it:

```bash
$ source ./.env
$ REPO="${ECR_ACCOUNTID}.dkr.ecr.${ECR_REGION}.amazonaws.com"
$ IMAGE="${REPO}/${COMPOSE_PROJECT_NAME}"
$ aws ecr get-login-password --region "${ECR_REGION}" | \
    docker login --username AWS --password-stdin "${IMAGE}"
$ docker pull "${IMAGE}:latest"
```

To push a new version (TODO: use better tags):

```bash
d$ docker-compose build
$ docker tag "${COMPOSE_PROJECT_NAME}_magento:latest" "${IMAGE}:latest"
$ docker push "${IMAGE}:latest"
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
`Xdebug` needs to know the address of the docker host in order to connect

```bash
cd "${NS8_SRC}/protect-tools-docker/magento"
source .env # loads COMPOSE_PROJECT_NAME
docker-compose stop magento # stop the instance so that it will see the new ENV values
DEBUG_IP=$(docker network inspect "${COMPOSE_PROJECT_NAME}_protect" \
| jq -r '.[0].IPAM.Config[0].Gateway')
echo "XDEBUG_CONFIG=\"remote_enable=1 remote_host=${DEBUG_IP}\"" >> .env
docker-compose up -d
```

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

1. Investigate `docker-compose.overrides.yml` (or similar) to compose with
   protect-api and client/middleware
2. VS Code `.devcontainer` can work well with remote docker hosts via SSH, and
   would give better support for non-PHP codebases
3. Use `k8s`/`minicube` instead of `docker-compose`?
