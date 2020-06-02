
# Magento

## Overview

The `magento` directory contains a `docker-compose` stack to enable docker-based testing and debugging for the [Magento integration](https://github.com/ns8inc/protect-integration-magento).

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

The Magento stack can be run alone, targeting the test deployment of protect at `https://test-protect.ns8.com` and `https://test-protect-client.ns8.com`, or with the protect API and client running alongside Magento in the stack. If you want to run the protect API and client in the stack, first [setup the `protect-client` stack](./protect-client.md).

### Getting the source

```bash
$ cd $NS8_SRC
$ git clone https://github.com/ns8inc/protect-tools-docker
$ git clone https://github.com/ns8inc/protect-integration-magento
$ get clone https://github.com/ns8inc/protect-switchboard-magento
$ # Optionally clone the php sdk, just for setting breakpoints
$ get clone https://github.com/ns8inc/protect-sdk-switchboard
```

### Deploying the Switchboard

If targeting `test`, there's no need to deploy the switchboard because requests will be sent by the protect API to the `ns8-switchboard-magento2-test` cloudformation stack. Otherwise, the switchboard must be deployed before the magento integration setup can complete successfully.

Before setting up the switchboard, you need to decide your `DEV_SUFFIX`.  Pick a value < 11 characters, ending with `-dev`.  The value needs to be short because it's included in AWS resource names, and picking one that's too long will result in the names exceeding their max length. It also needs to end in `-dev` so that your IAM permissions grant appropriate access to the resources.

```bash
$ cd $NS8_SRC/protect-switchboard-magento
$ cp .env.defaults .env
$ # edit the `.env` file to set `DEV_SUFFIX`, `NS8_CLIENT_URL`, and `NS8_PROTECT_URL`; e.g. with vs code:
$ code .env
$ yarn build 
$ yarn deploy
 < .. snipped prompts+output .. >
```

### Environment Vars

```bash
$ cd $NS8_SRC/protect-tools-docker/magento
$ cp .env.defaults .env
$ # edit the `.env` file to set the environment variables; e.g. with vs code:
$ code .env
```

 1. [General Variables](./overview.md#Environment)
 2. URLs
   - `MAGENTO_NGROK_SUBDOMAIN`: The subdomain used used by ngrok to make Magento accessible (you may want to [reserve](./overview.md#ngrok) ahead of time).
   - `MAGENTO_BASE_URL`: The URL set as the base URL for Magento (keep default)
   - `PROTECT_API_URL`: The URL of the protect API. If targeting the `test` instance, set to `https://test-protect.ns8.com`; if running as part of the stack copy the values (including the subdomain) from `protect-client/.env`
   - `PROTECT_CLIENT_URL`: The URL of the protect client. If targeting the `test` instance, set to `https://test-protect-client.ns8.com`; if running as part of the stack copy the values (including the subdomain) from `protect-client/.env`
 3. `INSTALL_DEV_PHP_SDK`: set this to `1` to have the setup script install the `dev-dev` version of the PHP sdk instead of the version referenced in `composer.json`. You can also do this manually after-the-fact in a shell for the `magento` service
 4. Composed project variables

    Unless targeting `test`, any variables that are required in `protect-client/.env` to run `protect-client/compose-all.sh` will must be defined in `magento/.env` when composing with that stack (i.e., when composing with other stacks it only loads the variables from the `.env` that's in the same directory as the `compose[-parts].sh` script).  Also, ensure you have `DEV_NAME` set in `$NS8_SRC/ns8-protect-api/.env` to match the `DEV_SUFFIX` set when deploying the switchboard, or the protect API will not send actions to your cloudformation stack.

### Docker Desktop configuration

Magento can be somewhat resource intensive; if running on Docker Desktop, it's advised to increase the resources dedicated to the docker VM.  6GB of RAM is recommended minimum, and increasing the CPU and swap size can make the Magento server much more responsive as well.

- Open Docker Desktop's preferences.
- Go to `Resources`.
- Increase the `CPUs`, `Memory`, and `Swap` to appropriate values for your machine.
- Click `Apply & Restart`.

### Starting the stack

After completing the steps above, you're ready to start the stack.  If you're targeting `test`:

```bash
$ cd $NS8_SRC/protect-tools-docker/magento
$ ./compose-mage-alone.sh up
```

Otherwise to start the stack with local protect API and client:

```bash
$ cd $NS8_SRC/protect-tools-docker/magento
$ ./compose-all.sh up
```

If this is the first time you've run the command, you'll want to work on something else as this will take a while.

## Development

### Services

The main service is `magento`:

```bash
$ cd $NS8_SRC/protect-tools-docker/magento
$ # Start all services/containers in the stack:
$ ./compose-all.sh up -d
$ # Follow the logs from magento (not really useful except during setup):
$ ./compose-all.sh log -f magento
$ # Start shell as `www-data` inside the container:
$ ./compose-all.sh exec magento /bin/bash
$ # Start shell as `root` inside the container:
$ ./compose-all.sh exec --user root magento /bin/bash
```

Other services that are useful to view the logs of are `protect-api` and `protect-client` (assuming they're running, and you're not targeting `test` with `./compose-mage-alone.sh`).

### Logging in

Once setup is complete, the Magento admin dashboard can be accessed at `https://{MAGENTO_NGROK_SUBDOMAIN}.ngrok.io/index.php/admin_demo`. The the default dev credentials are specified as the `--admin-user` and `--admin-password` parameters in [docker/setup-magento.sh](../magento/build-context/setup-magento.sh).

### Updating environment

Updating `MAGENTO_BASE_URL`, `PROTECT_API_URL` or `PROTECT_CLIENT_URL` in `.env` and then running `compose[-all].sh up` will cause docker-compose to recreate the container (these are the variables referenced in `docker-compose.yml`). If the container is recreated, it will reinstall magento and protect. Since the database volume is persistent, the install will be much faster the second time around, but you need to set `SKIP_CREATE_MAGENTO_DB=1` or the install process will fail (since the database already exists).

### Debugging

To enable `Xdebug`, you need to define the `XDEBUG_CONFIG` environment variable. `Xdebug` needs to know the address of the docker host in order to connect; if you're running on linux, you can get the IP with `docker network inspect`:

```bash
cd "${NS8_SRC}/protect-tools-docker/magento"
source .env # loads COMPOSE_PROJECT_NAME
./compose[-all].sh stop magento # stop the instance so that it will see the new ENV values
DEBUG_IP=$(docker network inspect "${COMPOSE_PROJECT_NAME}_protect" \
  | jq -r '.[0].IPAM.Config[0].Gateway')
echo "XDEBUG_CONFIG=\"remote_enable=1 remote_host=${DEBUG_IP}\"" >> .env
docker-compose up -d
```

If you're running `docker desktop`, the IP address returned from `docker network inspect` above will be the address of the linux VM where docker's running, not the IP that the PHP debugger listens on.  In that case, it's easiest to just set the `XDEBUG_CONFIG="remote_enable=1 remote_host=<YOUR IP>"` value manually in your `.env` file.

There's a `vs code` debug configuration in this project that can be used to start the debugger so that php can connect and hit breakpoints.

## Troubleshooting

### Magento Integration Install Action

When the Magento integration is setup, it sends an `INSTALL_ACTION` to protect to register the store with the system and retrieve an access token. *If the protect middleware and api are not running at this time, the install will fail.  Also, if the store's domain has been registered before, the install will fail*.

## TODO

https://app.clubhouse.io/ns8/story/24344/discovery-investigate-how-to-use-composer-to-install-magento-in-docker

If you are trying to setup Magento and there's already a merchant created with that domain, the installation will fail. There's [a ticket](https://app.clubhouse.io/ns8/story/24347/gracefully-handle-setup-install-failures) to enable setting the token through the admin interface in this case, but until then the easiest thing to do is just hack-in your token:

```diff
diff --git a/Helper/Setup.php b/Helper/Setup.php
index 01f5ff0..a9b448c 100644
--- a/Helper/Setup.php
+++ b/Helper/Setup.php
@@ -143,7 +143,7 @@ class Setup extends AbstractHelper
                 ];
 
                 $installResult = InstallerClient::install('magento', $installRequestData);
-                $this->config->setEncryptedConfigValue(Config::ACCESS_TOKEN_CONFIG_KEY, $installResult['accessToken']);
+                $this->config->setEncryptedConfigValue(Config::ACCESS_TOKEN_CONFIG_KEY, 'c5f2a6e6-4991-4598-aadd-15f03f209339'); //$installResult['accessToken']);
```
