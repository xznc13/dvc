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
for i in /initdbscripts/common/Tables/*
 do
  /usr/bin/echo "$0: running $i"
  /usr/bin/mysql -D ${DBNAME} < $i
 done
#
exit
