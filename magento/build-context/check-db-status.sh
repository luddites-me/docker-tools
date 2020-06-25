#!/bin/sh
MYSQL_SERVER="mysql"
MYSQL_PORT="3306"

RET=1
while [ $RET -ne 0 ]; do
    echo "\n* Checking if $MYSQL_SERVER is available..."
    mysql -h $MYSQL_SERVER -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD -e "status" > /dev/null 2>&1
    RET=$?
    if [ $RET -ne 0 ]; then
        echo "\n* Waiting for confirmation of MySQL service startup";
        sleep 5
    fi
done
echo "$MYSQL_SERVER is available, continuing..."