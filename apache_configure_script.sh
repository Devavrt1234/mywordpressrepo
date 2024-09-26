#!/bin/bash

# Exit script on error
set -e

echo "Starting Apache configuration for WordPress..."

# Variables (you can modify these according to your setup)
 
DOCUMENT_ROOT="/srv/www/wordpress"        # WordPress document root
APACHE_CONF="/etc/apache2/sites-available/wordpress.conf"
APACHE_DEFAULT_CONF="/etc/apache2/sites-enabled/000-default.conf"

# Ensure the document root directory exists
if [ ! -d "$DOCUMENT_ROOT" ]; then
    echo "Creating WordPress directory at $DOCUMENT_ROOT"
    sudo mkdir -p "$DOCUMENT_ROOT"
fi

# Set permissions to the WordPress directory
echo "Setting permissions for $DOCUMENT_ROOT"
sudo chown -R www-data:www-data "$DOCUMENT_ROOT"
sudo chmod -R 755 "$DOCUMENT_ROOT"

# Create Apache virtual host configuration
echo "Creating Apache virtual host configuration for WordPress..."

sudo bash -c "cat > $APACHE_CONF <<EOF
<VirtualHost *:80>
   
    DocumentRoot $DOCUMENT_ROOT
   

    <Directory $DOCUMENT_ROOT>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>

    <Directory $DOCUMENT_ROOT/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

# Enable the new site
echo "Enabling WordPress site configuration in Apache..."
sudo a2ensite wordpress

# Disable the default Apache site, if needed
if [ -f "$APACHE_DEFAULT_CONF" ]; then
    echo "Disabling default Apache site configuration..."
    sudo a2dissite 000-default
fi

# Enable Apache rewrite module (important for WordPress permalinks)
echo "Enabling Apache rewrite module..."
sudo a2enmod rewrite

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart apache2

echo "Apache has been configured for WordPress at $DOCUMENT_ROOT."
