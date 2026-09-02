#!/bin/sh
set -e

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! nc -z mariadb 3306; do
  sleep 1
done
echo "MariaDB is ready!"

# Create symlink for library assets if it doesn't exist
if [ ! -L "/var/www/html/libraries/lukida_newlibrary/systemassets" ]; then
    echo "Creating symlink for systemassets..."
    ln -s ../../kernel/application/systemassets /var/www/html/libraries/lukida_newlibrary/systemassets
    echo "Symlink created"
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html/libraries/lukida_newlibrary
chmod -R 755 /var/www/html/libraries/lukida_newlibrary

# Set permissions for log directories
chown -R www-data:www-data /var/log/apache2
chown -R www-data:www-data /var/log/php

echo "Lukida setup complete, starting Apache..."
exec "$@"