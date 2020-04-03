#!/bin/bash
count=120
while [ ${count} -ge 0 ]; do
    mysql -uroot -hdb -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" ${MYSQL_DATABASE}
    if [ $? -ne 0 ]; then
        ((count--))
        sleep 1
    else
        break
    fi
done

if [ $count -le 0 ]; then
    exit 1
fi

apache2-foreground
