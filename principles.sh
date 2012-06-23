#!/bin/sh

PASSWORD=$1
if [ -z $PASSWORD ]; then
    echo "Usage: principles.sh <interactive-client-password>"
    exit 1
fi

if [ -z $HOSTNAME ]; then
    HOSTNAME=`hostname -f`
fi
echo "using hostname: $HOSTNAME for server component of server principals."

KADMIN_LOCAL="sudo kadmin.local"
NORMAL_USER=`whoami`

#This script is idempotent: running it multiple times: re-running it
#results in the same state. Currently accomplished by deleting existing
#principles and keytabs, if any, and then (re-)creating.

#1. services
SERVICE_KEYTAB=services.keytab

rm -f `pwd`/$SERVICE_KEYTAB

#host
echo "delprinc -force host/$HOSTNAME" | $KADMIN_LOCAL
echo "addprinc -randkey host/$HOSTNAME" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB host/$HOSTNAME" | $KADMIN_LOCAL

#zookeeper
echo "delprinc -force zookeeper/$HOSTNAME" | $KADMIN_LOCAL
echo "addprinc -randkey zookeeper/$HOSTNAME" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB zookeeper/$HOSTNAME" | $KADMIN_LOCAL

#hdfs
echo "delprinc -force hdfs/$HOSTNAME" | $KADMIN_LOCAL
echo "addprinc -randkey hdfs/$HOSTNAME" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB hdfs/$HOSTNAME" | $KADMIN_LOCAL

#mapred
echo "delprinc -force mapred/$HOSTNAME" | $KADMIN_LOCAL
echo "addprinc -randkey mapred/$HOSTNAME" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB mapred/$HOSTNAME" | $KADMIN_LOCAL

sudo chown $NORMAL_USER `pwd`/$SERVICE_KEYTAB

#2. users
echo "delprinc -force zkclient" | $KADMIN_LOCAL
echo "addprinc -pw $PASSWORD zkclient" | $KADMIN_LOCAL

# only uncomment this if you want to use keytabs with client (rather
# than password).
#rm -f `pwd`/zkclient.keytab
#echo "ktadd -k `pwd`/zkclient.keytab zkclient" | $KADMIN_LOCAL
#sudo chown $NORMAL_USER `pwd`/zkclient.keytab
