#!/bin/bash
#
if [ "${DBNAME}" == "" ]
 then
  echo "The ENV variable DBNAME has not been defined, so exiting"
  exit 123
 else
  echo "Found variable DBNAME pointing to ${DBNAME}, continuing"
fi
#
/usr/bin/echo "Dropping Database ${DBNAME} - if it exists"
/usr/bin/mysql -e "DROP DATABASE IF EXISTS ${DBNAME}"
#
/usr/bin/echo "Creating Database ${DBNAME}"
/usr/bin/mysql -e "CREATE DATABASE ${DBNAME}"
#
/usr/bin/echo "List of Databases:-"
/usr/bin/mysql -e "SHOW DATABASES"
#
exit
