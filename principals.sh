#!/bin/sh

if [ -z $HOSTNAME ]; then
    HOSTNAME=`hostname -f`
fi
echo "using hostname: $HOSTNAME for instance component of"
echo "   server principals (service/instance@DOMAIN)."

KADMIN_LOCAL="sudo kadmin.local"
NORMAL_USER=`whoami`

#This script is idempotent: running it multiple times results in the same state.
#as if you only ran it once. Currently accomplished by deleting existing
#principles and keytabs, if any, and then (re-)creating.

SERVICE_KEYTAB=services.keytab
rm -f `pwd`/$SERVICE_KEYTAB


#1. services

#1.1. host
echo "delprinc -force host/$HOSTNAME" | $KADMIN_LOCAL
echo "addprinc -randkey host/$HOSTNAME" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB host/$HOSTNAME" | $KADMIN_LOCAL

#1.2. zookeeper
echo "delprinc -force zookeeper/$HOSTNAME" | $KADMIN_LOCAL
echo "addprinc -randkey zookeeper/$HOSTNAME" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB zookeeper/$HOSTNAME" | $KADMIN_LOCAL

#1.3. hdfs
echo "delprinc -force hdfs/$HOSTNAME" | $KADMIN_LOCAL
echo "addprinc -randkey hdfs/$HOSTNAME" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB hdfs/$HOSTNAME" | $KADMIN_LOCAL

#1.4. mapred
echo "delprinc -force mapred/$HOSTNAME" | $KADMIN_LOCAL
echo "addprinc -randkey mapred/$HOSTNAME" | $KADMIN_LOCAL
echo "ktadd -k `pwd`/$SERVICE_KEYTAB mapred/$HOSTNAME" | $KADMIN_LOCAL

sudo chown $NORMAL_USER `pwd`/$SERVICE_KEYTAB

#2. users

echo
PASSWORD1="null1"
PASSWORD2="null2"
while [ $PASSWORD1 != $PASSWORD2 ]; do

    echo -n "Password:"
    stty -echo
    read PASSWORD1
    echo
    echo -n "Repeat password:"
    stty -echo
    read PASSWORD2

    echo
    if [ $PASSWORD1 != $PASSWORD2 ]; then
       echo "passwords did not match: please try again."
    fi

done
stty echo

PASSWORD=$PASSWORD1

echo "delprinc -force `whoami`" | $KADMIN_LOCAL
echo "addprinc -pw $PASSWORD `whoami`" | $KADMIN_LOCAL

# only uncomment this if you want to use keytabs with client (rather
# than password).
#rm -f `pwd`/`whoami`.keytab
#echo "ktadd -k `pwd`/`whoami`.keytab `whoami`" | $KADMIN_LOCAL
#sudo chown $NORMAL_USER `pwd`/`whoami`.keytab
