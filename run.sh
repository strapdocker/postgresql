#!/bin/bash

echo "==========PostgreSQL INFO ========="

if [ -z $POSTGRESQL_USER ]; then
	POSTGRESQL_USER='pg-super'
fi

if [ -z $POSTGRESQL_PASS ]; then
	POSTGRESQL_PASS='insecurepass'
fi

POSTGRESQL_BIN=/usr/lib/postgresql/9.3/bin/postgres
POSTGRESQL_CONFIG_FILE=/etc/postgresql/9.3/main/postgresql.conf
POSTGRESQL_DATA=/var/lib/postgresql/9.3/main
POSTGRESQL_SINGLE="chpst -u postgres $POSTGRESQL_BIN --single --config-file=$POSTGRESQL_CONFIG_FILE"

if [ -e $FIRST_RUN_LOCK ]; then

    echo "****** First Time Run Detected - Creating User and Database ********"

    if [ ! -d $POSTGRESQL_DATA ]; then
        mkdir -p $POSTGRESQL_DATA
        chown -R postgres:postgres $POSTGRESQL_DATA
        sudo -u postgres /usr/lib/postgresql/9.3/bin/initdb -D $POSTGRESQL_DATA
    fi

    $POSTGRESQL_SINGLE <<< "DROP ROLE IF EXISTS \"$POSTGRESQL_USER\";" > /dev/null
    $POSTGRESQL_SINGLE <<< "CREATE ROLE \"$POSTGRESQL_USER\" WITH ENCRYPTED PASSWORD '$POSTGRESQL_PASS';" > /dev/null
    $POSTGRESQL_SINGLE <<< "ALTER ROLE \"$POSTGRESQL_USER\" WITH SUPERUSER;" > /dev/null
    $POSTGRESQL_SINGLE <<< "ALTER ROLE \"$POSTGRESQL_USER\" WITH LOGIN;" > /dev/null

    if [ ! -z $DB ]; then
        $POSTGRESQL_SINGLE <<< "CREATE DATABASE \"$DB\" WITH OWNER=\"$POSTGRESQL_USER\";" > /dev/null
        $POSTGRESQL_SINGLE <<< "GRANT ALL ON DATABASE \"$DB\" TO \"$POSTGRESQL_USER\";" > /dev/null

        echo "Database $DB created!"
    fi

    rm -f $FIRST_RUN_LOCK
fi

  echo "POSTGRES_USER=$POSTGRESQL_USER"
  echo "POSTGRES_PASS=$POSTGRESQL_PASS"
  echo "POSTGRES_DATA_DIR=$POSTGRESQL_DATA"

echo "==========END PostgreSQL Setup ========="

exec chpst -u postgres $POSTGRESQL_BIN --config-file=$POSTGRESQL_CONFIG_FILE