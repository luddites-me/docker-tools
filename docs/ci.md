
# Continuous Integration

## Overview

The `ci` directory contains Docker templates that will automatically generate a Docker image usable by CircleCI for automated testing. For the moment this lives separate and apart from the other contents of this repo, although work will be done in the near future to more closely integrate them and eliminate any redundancies.

## Generating PHP images

These images are intended to be used by the [protect-sdk-php](https://github.com/ns8inc/protect-sdk-php) repo, which currently needs to support PHP 7.1 through 7.4.

From the `ci` directory, run the following command and specify the PHP version number you want with `-p`:
```
$ yarn build:ns8-php -p 7.3
```

## Generating Magento images

These images are intended to be used by the [protect-integration-magento](https://github.com/ns8inc/protect-integration-magento) repo, which currently needs to support PHP 7.1 through 7.3 and Magento 2.3.1 through 2.3.5-p1 (although not every version of PHP is supported by every version of Magento).

From the `ci` directory, run the following command and specify the Magento version you want with `-m` and the PHP version number you want with `-p`:
```
$ yarn build:ns8-magento -m 2.3.4-p2 -p 7.2
```

## Deploying the images

Once you have created your image(s), you can tag them and push to ECR. Using the PHP image we created above as an example:
```
$ docker tag ns8-php:7.3 244249143763.dkr.ecr.us-west-2.amazonaws.com/ns8-php:7.3
$ aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 244249143763.dkr.ecr.us-west-2.amazonaws.com
$ docker push 244249143763.dkr.ecr.us-west-2.amazonaws.com/ns8-php:7.3
```

## Using the images

Once the images are deployed they can be used in a CircleCI `config.yml` file:
```
commands:
  test:
    description: "Run Your Tests"
    steps:
      - checkout
      - ...

jobs:
  test_7-2:
    docker:
      - image: 244249143763.dkr.ecr.us-west-2.amazonaws.com/ns8-php:7.2
    steps:
      - test
  test_7-3:
    docker:
      - image: 244249143763.dkr.ecr.us-west-2.amazonaws.com/ns8-php:7.3
    steps:
      - test
```
