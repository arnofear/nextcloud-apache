#!/bin/bash

echo "Updating permissions..."

# find "$NEXTCLOUD_DIR" \( ! -user www-data -o ! -group www-data \) -exec chown -R www-data:www-data {} \;
for subdir in data config apps; do
    find "$NEXTCLOUD_DIR/$subdir" \( ! -user www-data -o ! -group www-data \) -exec chown -R www-data:www-data {} \;
done

echo "Done updating permissions."

# https://docs.nextcloud.com/server/12/admin_manual/configuration_server/occ_command.html
if [ -f "$NEXTCLOUD_DIR/config/config.php" ]; then
    echo "Upgrading occ..."

    su -l www-data -s /bin/bash -c "/usr/local/bin/php -d memory_limit=$CRON_MEMORY_LIMIT -f $NEXTCLOUD_DIR/occ" upgrade
fi

echo "Start apache2."

/usr/local/bin/apache2-foreground &

echo "Start sleep loop."

while true; do
  su -l www-data -s /bin/bash -c "/usr/local/bin/php -d memory_limit=$CRON_MEMORY_LIMIT -f $NEXTCLOUD_DIR/cron.php"

  sleep 15m
done
