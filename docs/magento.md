
# Magento

## Overview

The `magento` directory contains a `docker-compose` stack to enable docker-based testing and debugging for the [Magento integration](https://github.com/luddites-me/protect-integration-magento).

## Setup

Before running any of this you need [the basic setup](./overview.md#setup).

The Magento stack can be run alone, targeting the test deployment of protect at `https://test-protect.luddites.me` and `https://test-protect-client.luddites.me`, or with the protect API and client running alongside Magento in the stack. If you want to run the protect API and client in the stack, first [setup the `protect-client` stack](./protect-client.md).

### Getting the source

```bash
$ cd $LUDDITES_SRC
$ git clone https://github.com/luddites-me/docker-tools
$ git clone https://github.com/luddites-me/protect-integration-magento
$ get clone https://github.com/luddites-me/protect-switchboard-magento
$ # Optionally clone the php sdk, just for setting breakpoints
$ get clone https://github.com/luddites-me/protect-sdk-switchboard
```


### Deploying the Switchboard

If targeting `test`, there's no need to deploy the switchboard because requests will be sent by the protect API to the `luddites-switchboard-magento2-test` cloudformation stack. Otherwise, the switchboard must be deployed before the magento integration setup can complete successfully.

Before setting up the switchboard, you need to decide your `DEV_SUFFIX`.  Pick a value < 11 characters, ending with `-dev`.  The value needs to be short because it's included in AWS resource names, and picking one that's too long will result in the names exceeding their max length. It also needs to end in `-dev` so that your IAM permissions grant appropriate access to the resources.

```bash
$ cd $LUDDITES_SRC/protect-switchboard-magento
$ cp .env.defaults .env
$ # edit the `.env` file to set `DEV_SUFFIX`; e.g. with vs code:
$ code .env
$ yarn build
$ yarn deploy
 < .. snipped prompts+output .. >
```

### Environment Vars

```bash
$ cd $LUDDITES_SRC/docker-tools/magento
$ cp .env.defaults .env
$ # edit the `.env` file to set the environment variables; e.g. with vs code:
$ code .env
```

 1. [General Variables](./overview.md#Environment)
 2. URLs
   - `MAGENTO_NGROK_SUBDOMAIN`: The subdomain used used by ngrok to make Magento accessible (you may want to [reserve](./overview.md#ngrok) ahead of time).
   - `MAGENTO_BASE_URL`: The URL set as the base URL for Magento (keep default)
   - `PROTECT_API_URL`: The URL of the protect API. If targeting the `test` instance, set to `https://test-protect.luddites.me`; if running locally, set the it to your protect api ngrok url
   - `PROTECT_CLIENT_URL`: The URL of the protect client. If targeting the `test` instance, leave it on `https://test-protect-client.luddites.me`, otherwise set it to the url of your ngrok instance;
 3. `INSTALL_DEV_PHP_SDK`: set this to `true` to have the setup script install the `dev-dev` version of the PHP sdk instead of the version referenced in `composer.json`. You can also do this manually after-the-fact in a shell for the `magento` service

### Docker Desktop configuration

Magento can be somewhat resource intensive; if running on Docker Desktop, it's advised to increase the resources dedicated to the docker VM.  6GB of RAM is recommended minimum, and increasing the CPU and swap size can make the Magento server much more responsive as well.

- Open Docker Desktop's preferences.
- Go to `Resources`.
- Increase the `CPUs`, `Memory`, and `Swap` to appropriate values for your machine.
- Click `Apply & Restart`.

### Starting the stack

After completing the steps above, you're ready to start the stack.  If you're targeting `test`:

```bash
$ cd $LUDDITES_SRC/docker-tools/magento
$ docker-compose up
```

If this is the first time you've run the command, you'll want to work on something else as this will take a while.

## Development

### Services

The main service is `magento`:

```bash
$ cd $LUDDITES_SRC/docker-tools/magento
$ # Start all services/containers in the stack:
$ docker-compose up -d
$ # Follow the logs from magento (not really useful except during setup):
$ docker-compose logs -f magento
$ # Start shell as `root` inside the container:
$ docker-compose exec magento /bin/bash
```

### Logging in

Once setup is complete, the Magento admin dashboard can be accessed at `https://{MAGENTO_NGROK_SUBDOMAIN}.ngrok.io/index.php/luddites_admin`(the admin path can be overridden with `BACKOFFICE_PATH`). The default dev credentials are specified as the `BACKOFFICE_USERNAME` and `BACKOFFICE_PASSWORD` parameters in [docker-compose.yaml](../magento/docker-compose.yaml).

### Updating environment

Updating `MAGENTO_BASE_URL`, `PROTECT_API_URL` or `PROTECT_CLIENT_URL` in `.env` and then running `docker-compose up` will cause docker-compose to recreate the container (these are the variables referenced in `docker-compose.yml`). If the container is recreated, it will reinstall magento and protect. Since the database didn't get recreated, the install will be much faster the second time around, but may potentially lead ot database corruption.

### Debugging

To enable `Xdebug`, you need to build the image with the build arg BUILD_ENABLE_XDEBUG=true, and define the `XDEBUG_CONFIG` environment variable. `Xdebug` needs to know the address of the docker host in order to connect; if you're running on linux, you can get the IP with `docker network inspect`:

```bash
cd "${LUDDITES_SRC}/docker-tools/magento"
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

https://app.clubhouse.io/luddites/story/24344/discovery-investigate-how-to-use-composer-to-install-magento-in-docker

If you are trying to setup Magento and there's already a merchant created with that domain, the installation will fail. There's [a ticket](https://app.clubhouse.io/luddites/story/24347/gracefully-handle-setup-install-failures) to enable setting the token through the admin interface in this case, but until then the easiest thing to do is just hack-in your token:


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
