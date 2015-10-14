#!/usr/bin/env bash

set -e

if [ -n "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ]; then
  # cd /var/www/auth/
  DB_NAME=${DB_NAME:-auth}
  DB_USER=${DB_USER:-auth}
  DB_PASS=${DB_PASS:-auth}
  DB_PORT=${DB_PORT:-$MYSQL_PORT_3306_TCP_PORT}
  DB_HOST=${DB_HOST:-$MYSQL_PORT_3306_TCP_ADDR}
  mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h$DB_HOST -P$DB_PORT mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; grant all on $DB_NAME.* to \"$DB_USER\"@\"%\" IDENTIFIED BY \"$DB_PASS\"; FLUSH PRIVILEGES;"
  
  echo "<?php
return array(
        'connections' => array(
                'mysql' => array(
                        'driver'    => 'mysql',
                        'host'      => '$DB_HOST',
                        'database'  => '$DB_NAME',
                        'username'  => '$DB_USER',
                        'password'  => '$DB_PASS',
                        'charset'   => 'utf8',
                        'collation' => 'utf8_unicode_ci',
                        'prefix'    => '',
                ),
        ),
);" > app/config/local/database.php


  php artisan migrate --package="lucadegasperi/oauth2-server-laravel" --env=local
  php artisan migrate --env=local

  admin_count=`mysql -h$DB_HOST -P$DB_PORT -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -BN -e 'select count(*) from oauth_scopes;' $DB_NAME`
  if [ $admin_count -eq 0 ]; then
    php artisan db:seed --env=local
  fi
else
 echo "DYING: please link a container named, 'mysql'"
 exit 1
fi

/usr/sbin/apache2ctl -D FOREGROUND