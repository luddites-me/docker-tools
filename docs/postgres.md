## Overview

The `postgres` directory contains a `docker-compose` stack to `postgres` and `pgadmin`, and expose `pgadmin` w/ `ngrok`.

### Configuration

 1. `PGADMIN_DEFAULT_EMAIL`
  - set to the email/username you want to use to login to `pgadmin`
 2. `PGADMIN_DEFAULT_PASSWORD`
  - set to the password you want to use to login to `pgadmin`
 3. `PGADMIN_SUBDOMAIN`
  - default: ${NGROK_SUBDOMAIN_PREFIX}-pgadmin
  - the subdomain used used by ngrok to make the `pgadmin` accessible (you may want to [reserve](./overview.md#ngrok) ahead of time)
 4. `POSTGRES_USERNAME`
  - default: postgres
 5. `POSTGRES_PASSWORD`
  - default: postgres
