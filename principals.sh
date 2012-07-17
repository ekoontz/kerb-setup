#!/bin/sh
REALM=HADOOP.LOCALDOMAIN
PASSWORD=$1
if [ -z $PASSWORD ]; then
    echo "Usage: principles.sh <interactive-client-password>"
    exit 1
fi

if [ -z $HOSTNAME ]; then
    HOSTNAME=`hostname -f`
fi
echo "using hostname: $HOSTNAME for instance component of"
echo "   server principals (service/instance@REALM)."

KADMIN_LOCAL="sudo kadmin.local"
NORMAL_USER=`whoami`

#This script is idempotent: running it multiple times results in the same state.
#as if you only ran it once. Currently accomplished by deleting existing
#principles and keytabs, if any, and then (re-)creating.

SERVICE_KEYTAB=services.keytab
rm -f `pwd`/$SERVICE_KEYTAB


#1. services

#1.1. host
echo "delprinc -force host/$HOSTNAME@$REALM" | $KADMIN_LOCAL
echo "addprinc -randkey host/$HOSTNAME@$REALM" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB host/$HOSTNAME/@$REALM" | $KADMIN_LOCAL

#1.2. zookeeper
echo "delprinc -force zookeeper/$HOSTNAME/@$REALM" | $KADMIN_LOCAL
echo "addprinc -randkey zookeeper/$HOSTNAME/@$REALM" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB zookeeper/$HOSTNAME/@$REALM" | $KADMIN_LOCAL

#1.3. hdfs
echo "delprinc -force hdfs/$HOSTNAME@$REALM" | $KADMIN_LOCAL
echo "addprinc -randkey hdfs/$HOSTNAME@$REALM" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB hdfs/$HOSTNAME@$REALM" | $KADMIN_LOCAL

#1.4. mapred
echo "delprinc -force mapred/$HOSTNAME@$REALM" | $KADMIN_LOCAL
echo "addprinc -randkey mapred/$HOSTNAME@$REALM" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB mapred/$HOSTNAME@$REALM" | $KADMIN_LOCAL

sudo chown $NORMAL_USER `pwd`/$SERVICE_KEYTAB

#2. users
echo "delprinc -force `whoami`/@$REALM" | $KADMIN_LOCAL
echo "addprinc -pw $PASSWORD `whoami`/@$REALM" | $KADMIN_LOCAL

# only uncomment this if you want to use keytabs with client (rather
# than password).
#rm -f `pwd`/`whoami`.keytab
#echo "ktadd -k `pwd`/`whoami`.keytab `whoami`/@$REALM" | $KADMIN_LOCAL
#sudo chown $NORMAL_USER `pwd`/`whoami`.keytab
