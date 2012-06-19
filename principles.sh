#!/bin/sh
if [ -z $HOSTNAME ]; then
    HOSTNAME=`hostname -f`
fi
echo $HOSTNAME

PASSWORD=$1
KADMIN_LOCAL="sudo kadmin.local"
NORMAL_USER=`whoami`

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

# only uncomment this if you want to use keytabs with client (rather
# than password).
rm -f `pwd`/zkclient.keytab
echo "ktadd -k `pwd`/zkclient.keytab zkclient" | $KADMIN_LOCAL
sudo chown $NORMAL_USER `pwd`/zkclient.keytab
