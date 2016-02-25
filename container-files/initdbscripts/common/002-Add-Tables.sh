#!/bin/bash
#
if [ "${DBNAME}" == "" ]
    then
	/usr/bin/echo "The ENV variable DBNAME has not been defined, so no tables to add"
    else
	/usr/bin/echo "Found variable DBNAME pointing to ${DBNAME}, continuing"
	for i in /initdbscripts/common/Tables/*
	  do
	    /usr/bin/echo "$0: running $i"
	    /usr/bin/mysql -D ${DBNAME} < $i
	  done
fi
