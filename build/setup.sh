#!/bin/bash
set -eo pipefail

# Enable PHP 
add-apt-repository -y ppa:ondrej/php 

# Enable nginx repo
curl -s https://nginx.org/keys/nginx_signing.key | apt-key add -
add-apt-repository 'deb http://nginx.org/packages/ubuntu/ bionic nginx'

# Update installed packages
apt-get -y update 
apt-get -y dist-upgrade 

# Install nginx and PHP
apt-get -y install nginx php$PHP_VERSION-fpm php$PHP_VERSION-mysql php$PHP_VERSION-common php-apcu php-geoip \
	php-imagick php-igbinary php-memcached php-redis php$PHP_VERSION-bcmath php$PHP_VERSION-dba \
	php$PHP_VERSION-enchant php$PHP_VERSION-gd php$PHP_VERSION-imap php$PHP_VERSION-intl \
	php$PHP_VERSION-json php$PHP_VERSION-pspell php$PHP_VERSION-tidy php$PHP_VERSION-xml \
	php$PHP_VERSION-xmlrpc php-pear php$PHP_VERSION-zip php$PHP_VERSION-bz2 php$PHP_VERSION-mbstring  php$PHP_VERSION-curl \
	php$PHP_VERSION-pgsql php$PHP_VERSION-ldap php$PHP_VERSION-sqlite3

if [[ "$PHP_VERSION" != '7.4' ]]
then
	apt-get -y install php$PHP_VERSION-recode
fi

mkdir /var/www 
ln -sf /dev/stdout /var/log/nginx/access.log 
ln -sf /dev/stderr /var/log/nginx/error.log 
rm /etc/nginx/conf.d/*
echo "<?php phpinfo(); ?>" > /var/www/index.php
chown -R app:app /var/www

# Change max execution time to 180 seconds
sed -ri 's/(max_execution_time =) ([2-9]+)/\1 180/' /etc/php/$PHP_VERSION/fpm/php.ini 

# Max memory to allocate for each php-fpm process
sed -ri 's/(memory_limit =) ([0-9]+)/\1 1024/' /etc/php/$PHP_VERSION/fpm/php.ini 

# Set the timezone - This is my default
sed -ri 's/;(date.timezone =)/\1 Europe\/Copenhagen/' /etc/php/$PHP_VERSION/fpm/php.ini 

# Install default conf

# Install Dockerize
wget -qO - https://github.com/jwilder/dockerize/releases/download/v0.5.0/dockerize-linux-amd64-v0.5.0.tar.gz \
	| tar zxf - -C /usr/local/bin

# Cleanup
/usr/local/sbin/cleanup.sh
