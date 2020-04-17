ARG PHP_VERSION=7.3
FROM php:${PHP_VERSION}-apache

ARG MAGENTO_VERSION=2.3.4

ENV MAGEUSER=MAG005397149
ENV MAGEPASS=2f7e27231024a6cbc3e075f5a74b8264e6badb56

ENV MAGENTO_INSTALLER_DIR=/tmp

RUN cd "${MAGENTO_INSTALLER_DIR}" && \
  curl -O "https://${MAGEUSER}:${MAGEPASS}@www.magentocommerce.com/products/downloads/file/Magento-CE-${MAGENTO_VERSION}_sample_data.zip"

# Install generally useful utilities
RUN apt update -y && \
  apt install -y jq unzip

# Install native libraries for magento required php extensions
RUN apt install -y libicu-dev \
    zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxslt1-dev \
    libzip-dev

# Install cron to support Magento's cron jobs
RUN apt install -y cron supervisor

# Set the php.ini file for development
RUN mv "${PHP_INI_DIR}/php.ini-development" "${PHP_INI_DIR}/php.ini"

# Change php memory limit to '-1' // Magento wants > 2GB
RUN sed -i 's/^\(memory_limit =\).*$/\1 -1/' "${PHP_INI_DIR}/php.ini"

# Install mysql extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install Magento required php extensions
RUN docker-php-ext-configure gd \
  --with-freetype-dir=/usr/include \
  --with-jpeg-dir=/usr/include \
  && docker-php-ext-install gd \
    intl bcmath xsl soap zip sockets

# Enable required apache modules
RUN a2enmod expires headers rewrite

# Install Xdebug
RUN pecl install xdebug \
  && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" \
    > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Set the run user/group
# .. We could do everything as `root`, but this is closer to what
#    a non-dev instance would run as.  The container must be run
#    with `--sysctls net.ipv4.ip_unprivileged_port_start=0` when
#    this is set to non-root and binding to port < 1024.
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

# `/var/www` is the home directory for user `www-data`
RUN chown www-data:www-data /var/www
USER www-data
WORKDIR /var/www

RUN cd "${MAGENTO_INSTALLER_DIR}" && \
  unzip -qq "./Magento-CE-${MAGENTO_VERSION}_sample_data.zip" -d /var/www/html

# Set `composer` path
ENV COMPOSER_HOME=/var/www/html/var/composer_home

ENV MAGE_COMPOSER_REPO_PUBKEY=1b8325eb6d792fe22c0fb83f65150281
ENV MAGE_COMPOSER_REPO_PRIVKEY=d68ff7618b2f3118a0342d7f914848c8

COPY --chown=www-data:www-data \
  create-magento-db.php \
  setup-and-run.sh \
  setup-magento.sh \
  setup-protect.sh \
  setup-update-config.sh \
  try-connect-magento-db.php ./

USER root
COPY ./supervisord.conf .
CMD ["/usr/bin/supervisord", "-c", "./supervisord.conf"]
