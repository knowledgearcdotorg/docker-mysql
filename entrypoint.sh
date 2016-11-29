#!/bin/bash

# Create a random string and use it as MySQL's root password.
# The password is output to the screen or is available via docker logs.

DATADIR="$(/usr/sbin/mysqld --verbose --help --log-bin-index=/tmp/tmp.index 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"

echo $DATADIR

if [ ! -d "$DATADIR/mysql" ]; then
    echo "initializing mysql data store for the first time..."

    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        MYSQL_ROOT_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
        echo "root:$MYSQL_ROOT_PASSWORD"
    fi

    echo "creating $DATADIR..."
    mkdir -p "$DATADIR"
    chown -R mysql:mysql "$DATADIR"

    echo "initializing..."
    /usr/sbin/mysqld \
        --initialize-insecure
    echo "initialized"

    echo "starting mysql..."
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
    echo "mysql started"

    DEBIAN_SYS_MAINT_PASSWORD="$(cat /etc/mysql/debian.cnf | awk '$1 == "password" { print $3; exit }')"

    # add the user with the reload right
    /usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DEBIAN_SYS_MAINT_PASSWORD';"
    /usr/bin/mysql -u root -e "FLUSH PRIVILEGES;"

    /usr/bin/mysqladmin password $MYSQL_ROOT_PASSWORD

    /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
else
    echo "MySQL Database already exists. Doing nothing."
fi

exec "$@"
