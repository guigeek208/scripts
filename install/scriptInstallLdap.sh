#!/bin/bash
#
# Installation automatique de OpenLDAP + LdapAccountManager
#
# Guillaume ROCHE
#
# Syntaxe: root> ./scriptInstallLdap.sh
#

FILE=$PWD/ldap-sel.txt
DOMAIN="domain.org"
ORG="domain"
PASSWORD="password"
SED=/bin/sed
ZCAT=/bin/zcat
SLAPCAT=/usr/sbin/slapcat
TREE=`echo $DOMAIN |cut -d"." -f1`
SUFFIX=`echo $DOMAIN |cut -d"." -f2`

WHOAMI=`/usr/bin/whoami`
if [ $WHOAMI != "root" ]; then
   echo -e "You must be root to install ldap packages\n"
   exit 1
fi

echo "slapd	slapd/allow_ldap_v2	boolean	false" > $FILE
echo "#slapd	slapd/password_mismatch	note" >> $FILE
echo "#slapd	slapd/invalid_config	boolean	true" >> $FILE
echo "slapd	shared/organization	string	$ORG" >> $FILE
echo "#slapd	slapd/dump_database_destdir	string	/var/backups/slapd-VERSION" >> $FILE
echo "#slapd	slapd/upgrade_slapcat_failure	error" >> $FILE
echo "slapd	slapd/purge_database	boolean	false" >> $FILE
echo "slapd	slapd/domain	string	$DOMAIN" >> $FILE
echo "slapd	slapd/backend	select	HDB" >> $FILE
echo "#slapd	slapd/no_configuration	boolean	false" >> $FILE
echo "slapd	slapd/move_old_database	boolean	true" >> $FILE
echo "slapd	slapd/password2	password $PASSWORD" >> $FILE
echo "slapd	slapd/password1	password $PASSWORD" >> $FILE

debconf-set-selections $FILE
DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils ldap-account-manager

$SED -s -i "s;dc=my-domain,dc=com;dc=$TREE,dc=$SUFFIX;" /var/lib/ldap-account-manager/config/lam.conf
$SED -s -i "s;cn=Manager;cn=admin;" /var/lib/ldap-account-manager/config/lam.conf
$SED -s -i "s;dc=yourdomain,dc=org;dc=$TREE,dc=$SUFFIX;" /var/lib/ldap-account-manager/config/lam.conf

# Modifier le ldap pour l'accueil du samba

DEBIAN_FRONTEND=noninteractive apt-get install -y samba-doc smbldap-tools 
$ZCAT /usr/share/doc/samba-doc/examples/LDAP/samba.schema.gz > /etc/ldap/schema/samba.schema

echo "include          /etc/ldap/schema/core.schema" > /etc/ldap/samba.ldif
echo "include          /etc/ldap/schema/cosine.schema" >> /etc/ldap/samba.ldif
echo "include          /etc/ldap/schema/nis.schema" >> /etc/ldap/samba.ldif
echo "include          /etc/ldap/schema/inetorgperson.schema" >> /etc/ldap/samba.ldif
echo "include          /etc/ldap/schema/samba.schema" >> /etc/ldap/samba.ldif

# Convertir ce fichier en une série de fichiers LDIF pour OpenLDAP

mkdir /tmp/slapd.d/
$SLAPCAT -f /etc/ldap/samba.ldif -F /tmp/slapd.d -n0 -s "cn={4}samba,cn=schema,cn=config" > /tmp/cn=samba.ldif
cp /tmp/slapd.d/cn\=config/cn\=schema/cn\=\{4\}samba.ldif /etc/ldap/slapd.d/cn\=config/cn\=schema/
chown openldap:openldap /etc/ldap/slapd.d/cn\=config/cn\=schema/cn\=\{4\}samba.ldif
service slapd restart
