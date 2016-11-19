#!/bin/bash

# Create a random string and use it as MySQL's root password.
# The password is output to the screen and is saved to /root/config/mysql.

PCONFIG=/root/config
FMYSQL=$PCONFIG/mysql

if [ ! -f $FMYSQL ]; then
    MYSQL_ROOT_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"

    /usr/bin/mysqld_safe \
        --user=mysql \
        --skip-networking \
        --pid-file=/var/run/mysqld/mysqld.pid > /dev/null 2>&1 &

    timeout=30
    while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
    do
      timeout=$(($timeout - 1))
      if [ $timeout -eq 0 ]; then
        echo -e "\nCould not connect to database server. Aborting..."
        exit 1
      fi
      echo -n "."
      sleep 1
    done

    /usr/bin/mysqladmin password $MYSQL_ROOT_PASSWORD

    /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown

    mkdir $PCONFIG
    touch $FMYSQL
    echo "mysql_root_password=$MYSQL_ROOT_PASSWORD" >> $FMYSQL

    echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
fi

exec "$@"

