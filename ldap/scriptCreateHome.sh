#!/bin/bash
# Author Guillaume Roche <groche@guigeek.org>
#

HOST=$1
CN=$2
DN=$3
PASS=$4

usage()
{
    echo -en "Usage:\t./scriptCreateHome.sh <host-ldap> <cn> <dn> <pass>\n\nContact: <groche@guigeek.org>\n"
}
 
if [ -z $HOST ]; then
    usage
elif [ -z $CN ]; then
    usage
elif [ -z $DN ]; then
    usage
elif [ -z $PASS ]; then
    usage
else
    liste=`ldapsearch -h $HOST -w $PASS -D $CN -b $DN | grep homeDirectory | cut -d" " -f2`
    for home in $liste 
    do
        login=`echo $home| cut -d"/" -f4`
        test -d $home
        if [ "$?" -ne "0" ]; then
            echo "create $home"
            mkdir $home
            chown $login:grp_users $home
            chmod 700 $home
        fi
    done
fi
