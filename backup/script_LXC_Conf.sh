#!/bin/bash

VAR_CLIENT="NOM-DU-CLIENT"
VAR_MAILFROM="backup@xxxxx.xx"
VAR_MAILRCPT="backup@bh-consulting.net"

###############################################################

MAIL=/usr/sbin/sendmail
CAT=/bin/cat
TAR=/bin/tar
DATE=/bin/date
UUENCODE=/usr/bin/uuencode
ECHO=/bin/echo
SED=/bin/sed
HEAD=/usr/bin/head

TIMEDATE=`$DATE +%F`
MSG=/tmp/mail.txt


PATH_LXC=/var/lib/lxc

function backup_etc {
  PATH=$PATH_LXC$1/rootfs/etc
  echo $PATH
  $TAR czvf /tmp/conf_$TIMEDATE_$1.tar.gz $PATH > /dev/null 2> /dev/null
}


function mail_main {
  $ECHO "From: "$VAR_MAILFROM >| $MSG
  $ECHO "To: "$VAR_MAILRCPT >> $MSG
  $ECHO "Subject: [CONF] "$VAR_CLIENT >> $MSG
  $ECHO "Content-type: multipart/mixed; boundary=\"idalacon\"" >> $MSG
  $ECHO "Mime-version: 1.0" >> $MSG

  $ECHO "--idalacon" >> $MSG
  $ECHO "Content-Type: text/plain; charset=\"UTF-8\"" >> $MSG
  $ECHO "Content-Transfer-Encoding: 8bit" >> $MSG
  $ECHO "" >> $MSG
  $CAT /etc/lsb-release >> $MSG

  $ECHO "--idalacon" >> $MSG
}

function mail_join {
  $ECHO "Content-Transfer-Encoding: base64" >> $MSG
  $ECHO "Content-Type: application/gzip; name=\"conf_$TIMEDATE_$1.tar.gz\"; charset="UTF-8"" >> $MSG
  $ECHO "Content-Disposition: attachment; filename=\"conf_$TIMEDATE_$1.tar.gz\"" >> $MSG
  $ECHO "" >> $MSG
  $UUENCODE --base64 /tmp/conf_$TIMEDATE_$1.tar.gz conf_$TIMEDATE_$1.tar.gz | $SED 1,1d | $HEAD -n -1 >> $MSG
  $ECHO "--idalacon--" >> $MSG
}

#mail_main
for inode in /home/guigui/*
do
  if [ -d $inode ]; then
    echo $inode |rev |cut -d"/" -f1 |rev
    #backup_etc $inode
    #mail_join $inode
  fi
done
#$MAIL $VAR_MAILRCPT < $MSG

