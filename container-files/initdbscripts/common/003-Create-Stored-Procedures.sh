#!/bin/bash
#
if [ "${DBNAME}" == "" ]
    then
	/usr/bin/echo "The ENV variable DBNAME has not been defined, so exiting"
    else
	/usr/bin/echo "Found variable DBNAME pointing to ${DBNAME}, continuing"
	for i in /initdbscripts/common/Procedures/*
	  do
	   /usr/bin/echo "$0: running $i"
	   /usr/bin/mysql -D ${DBNAME} < $i
	  done
fi
