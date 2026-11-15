#!/bin/bash

set -e

# 1. Update the system
apt-get update -y
apt-get upgrade -y

# 2. Install Apache, PHP, and MySQL (MariaDB)
# We install all the necessary PHP extensions WordPress needs
apt-get install -y apache2 \
                 php \
                 php-mysql \
                 libapache2-mod-php \
                 php-cli \
                 php-cgi \
                 php-curl \
                 php-gd \
                 php-mbstring \
                 php-xml \
                 mariadb-server \
                 wget \
                 unzip

# 3. Start and enable the services
systemctl start apache2
systemctl enable apache2
systemctl start mariadb
systemctl enable mariadb

# 4. Configure the Database
# We are creating a DB called 'wordpress', a user called 'wpuser', and setting a password
# (Note: In a real production environment, don't hardcode the password!)
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="SuperSecretPassword123!"

mysql -e "CREATE DATABASE ${DB_NAME};"
mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# 5. Download and Extract WordPress
cd /tmp
wget -c https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# 6. Move WordPress to the Apache web directory and clean up the default HTML page
rm -rf /var/www/html/*
cp -r /tmp/wordpress/* /var/www/html/

# 7. Configure wp-config.php
# We copy the sample config and use 'sed' to replace the placeholder database details with our real ones
cd /var/www/html/
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
sed -i "s/username_here/${DB_USER}/" wp-config.php
sed -i "s/password_here/${DB_PASS}/" wp-config.php

# 8. Set file permissions
# Apache runs as the 'www-data' user. It needs ownership of the files to install themes/plugins.
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# 9. Restart Apache to apply everything
systemctl restart apache2
