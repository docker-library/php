#!/bin/bash
set -e

docker-php-ext-install mysql mysqli pdo pdo_mysql mcrypt mbstring ftp

cp /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

echo "Modifying privileges on /var/www/html"
# Set proper permissions to files and folders
find /var/www/html -type d -exec chmod -R 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

chown -R www-data:www-data /var/www/html;

exec "$@"
