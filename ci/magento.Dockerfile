ARG PHP_VERSION

FROM php:${PHP_VERSION}-apache

ARG MAGENTO_VERSION

ADD https://luddites-magento-installers.s3.amazonaws.com/Magento-CE-${MAGENTO_VERSION}_sample_data.zip /tmp/magento.zip

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    mkdir -p /usr/share/man/man1 && \
    apt-get install -y chromium-driver cron default-mysql-server git gnupg jq libicu-dev libjpeg-dev libpng-dev libxslt1-dev libzip-dev openjdk-11-jre-headless unzip wget yarnpkg

# PHP 7.4 replaced the `--with-jpeg-dir` option with `--with-jpeg`. We can use dpkg to compare semvers.
RUN dpkg --compare-versions "$( php -i | grep PHP_VERSION | head -n1 | awk '{print $3}' )" gt 7.4 \
    && docker-php-ext-configure gd --with-jpeg \
    || docker-php-ext-configure gd --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install bcmath gd intl pdo_mysql soap sockets xsl zip

RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

RUN sed 's/memory_limit = [[:digit:]]*M/memory_limit = 4096M/g' /usr/local/etc/php/php.ini-development > /usr/local/etc/php/php.ini

RUN cd /tmp && \
    expected_signature="$(wget -q -O - https://composer.github.io/installer.sig)" && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    actual_signature="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" && \
    if [ "$expected_signature" != "$actual_signature" ]; then \
    >&2 echo 'ERROR: Invalid installer signature' && \
    exit 1; \
    fi && \
    php composer-setup.php --filename=composer --install-dir=/usr/local/bin --quiet

RUN curl https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

RUN apt-get install apt-transport-https && \
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" >> /etc/apt/sources.list.d/elastic-7.x.list

RUN apt-get update && apt-get install -y elasticsearch

RUN unzip /tmp/magento.zip -d /var/www/html

RUN composer install -d /var/www/html --no-ansi

RUN service mysql start && \
    service elasticsearch start && \
    mysqladmin create magento2 && \
    mysql -e "GRANT ALL PRIVILEGES ON magento2.* TO 'magento_db_user'@'localhost' IDENTIFIED BY 'magento_db_password'" && \
    /var/www/html/bin/magento setup:install \
    --admin-email=dev@luddites.me \
    --admin-firstname=Development \
    --admin-lastname=Testing \
    --admin-password=secret1 \
    --admin-user=development \
    --backend-frontname=admin_demo \
    --base-url=http://localhost \
    --db-host=127.0.0.1 \
    --db-name=magento2 \
    --db-password=magento_db_password \
    --db-user=magento_db_user \
    --language=en_US \
    --timezone=America/Los_Angeles && \
    service mysql stop
