#!/bin/bash
#
if [ "${DBNAME}" == "" ]
    then
	/usr/bin/echo "The ENV variable DBNAME has not been defined, so not creating a new database"
    else
	/usr/bin/echo "Found variable DBNAME pointing to ${DBNAME}, continuing"
	/usr/bin/echo "Dropping Database ${DBNAME} - if it exists"
	/usr/bin/mysql -e "DROP DATABASE IF EXISTS ${DBNAME}"
#
	/usr/bin/echo "Creating Database ${DBNAME}"
	/usr/bin/mysql -e "CREATE DATABASE ${DBNAME}"
#
	/usr/bin/echo "List of Databases:-"
	/usr/bin/mysql -e "SHOW DATABASES"
fi
#
