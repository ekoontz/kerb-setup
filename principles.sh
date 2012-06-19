#!/bin/sh
if [! $HOSTNAME ]; then
    HOSTNAME=`hostname -f`
fi

PASSWORD=$1
KADMIN_LOCAL="sudo kadmin.local"
NORMAL_USER=`whoami`
set -x

#This script is idempotent: deletes existing principles and keytabs, if any,
#before recreating.

#1. services
echo "delprinc -force zookeeper/$HOSTNAME" | $KADMIN_LOCAL
echo "addprinc -randkey zookeeper/$HOSTNAME" | $KADMIN_LOCAL
rm -f `pwd`/zookeeper.keytab
echo "ktadd -k `pwd`/zookeeper.keytab zookeeper/$HOSTNAME" | $KADMIN_LOCAL
sudo chown $NORMAL_USER `pwd`/zookeeper.keytab

#2. users
echo "delprinc -force zkclient" | $KADMIN_LOCAL
echo "addprinc -pw $PASSWORD zkclient" | $KADMIN_LOCAL
