ARG PHP_VERSION

FROM php:${PHP_VERSION}-cli

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y awscli git jq unzip wget yarnpkg zip && \
    ln -s /usr/bin/yarnpkg /usr/local/bin/yarn

RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

RUN cd /tmp && \
    expected_signature="$(wget -q -O - https://composer.github.io/installer.sig)" && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    actual_signature="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" && \
    if [ "$expected_signature" != "$actual_signature" ]; then \
        >&2 echo 'ERROR: Invalid installer signature' && \
        exit 1; \
    fi && \
    php composer-setup.php --filename=composer --install-dir=/usr/local/bin --quiet
