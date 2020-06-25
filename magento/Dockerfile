ARG PHP_VERSION=7.3
FROM php:${PHP_VERSION}-apache

ARG MAGENTO_VERSION=2.3.4

ENV MAGEUSER=MAG005397149
ENV MAGEPASS=2f7e27231024a6cbc3e075f5a74b8264e6badb56

ENV MAGENTO_INSTALLER_DIR=/tmp

RUN cd "${MAGENTO_INSTALLER_DIR}" && \
  curl -O "https://${MAGEUSER}:${MAGEPASS}@www.magentocommerce.com/products/downloads/file/Magento-CE-${MAGENTO_VERSION}.zip"

ARG BUILD_ENABLE_XDEBUG=false

# Install generally useful utilities
RUN apt update -y \
  && apt install -y \
    jq unzip \
    default-mysql-client \
# Install native libraries for magento required php extensions
    libicu-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxslt1-dev \
    libzip-dev \
# Install cron to support Magento's cron jobs
    cron \
#cleanup apt packages
  && rm -rf /var/lib/apt/lists/* \
# Set the php.ini file for development
  && mv "${PHP_INI_DIR}/php.ini-development" "${PHP_INI_DIR}/php.ini" \
# Change php memory limit to '-1' // Magento wants > 2GB
  && sed -i 's/^\(memory_limit =\).*$/\1 -1/' "${PHP_INI_DIR}/php.ini" \
# Install mysql extensions
  && docker-php-ext-install mysqli pdo pdo_mysql \
# Install Magento required php extensions
  && docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include \
    --with-jpeg-dir=/usr/include \
  && docker-php-ext-install gd \
    intl bcmath xsl soap zip sockets \
# Enable required apache modules
  && a2enmod expires headers rewrite \
  && cd "${MAGENTO_INSTALLER_DIR}" \
  &&  unzip -qq "./Magento-CE-${MAGENTO_VERSION}.zip" -d /var/www/html \
# `/var/www` is the home directory for user `www-data`
  && chown -R www-data:www-data /var/www \
# Install Xdebug
  && [ $BUILD_ENABLE_XDEBUG = "true" ] && pecl install xdebug || true \
  && [ $BUILD_ENABLE_XDEBUG = "true" ] && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" \
    > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini || true \
  && chown -R www-data:www-data /var/www/html && chmod -R g+s /var/www/html

# Set the run user/group
# .. We could do everything as `root`, but this is closer to what
#    a non-dev instance would run as.  The container must be run
#    with `--sysctls net.ipv4.ip_unprivileged_port_start=0` when
#    this is set to non-root and binding to port < 1024.


WORKDIR /var/www/html

COPY --chown=www-data:www-data \
  check-db-status.sh \
  setup-and-run.sh \
  setup-magento.sh \
  setup-protect.sh \
  setup-update-config.sh \
  wait-for-protect.sh /tmp/

# Set `composer` path
ENV COMPOSER_HOME=/var/www/html/var/composer_home
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV MAGE_COMPOSER_REPO_PUBKEY=1b8325eb6d792fe22c0fb83f65150281
ENV MAGE_COMPOSER_REPO_PRIVKEY=d68ff7618b2f3118a0342d7f914848c8
ENV MAGENTO_INSTALL_DIR=/var/www/html
ENV BIN_MAGENTO="${MAGENTO_INSTALL_DIR}/bin/magento"
ENV BIN_COMPOSER="${MAGENTO_INSTALL_DIR}/vendor/composer/composer/bin/composer"

# Run
# USER www-data
# CMD ["/usr/bin/supervisord", "-c", "/tmp/supervisord.conf"]
CMD ["/bin/bash", "/tmp/setup-and-run.sh"]