#!/bin/bash
# Zimbra Backup Script
# This script is intended to run from the crontab as root
# Guillaume Roche - 2013

VAR_CLIENT="BHC"
VAR_SRCTITLE="Zimbra"
VAR_TYPE="Locale"
VAR_START_HOUR=`/bin/date +%H:%M`
VAR_MAILFROM="backup@bh-consulting.net"
VAR_MAILRCPT="backup@bh-consulting.net"

ECHO=/bin/echo
CAT=/bin/cat
MAIL=/usr/sbin/sendmail
TAIL=/usr/bin/tail
WGET=/usr/bin/wget
CUT=/usr/bin/cut
GREP=/bin/grep
DF=/bin/df
MKDIR=/bin/mkdir
DIRNAME=/usr/bin/dirname
DATE=/bin/date
PWD=`cd -P $( $DIRNAME $0 ); /bin/pwd`

if [ ! -e $PWD/logs ] 
then 
  $MKDIR $PWD/logs
fi  

LOG=$PWD"/logs/"`$DATE +%F_%X`".log"
# Outputs the time the backup started, for log/tracking purposes
echo Time backup started = $(date +%T) > $LOG
before="$(date +%s)"

$ECHO "-----------DEBUT------------" >> $LOG
$ECHO `$DATE` >> $LOG
$ECHO "-----------------------------" >> $LOG
rsync -avHK --exclude 'data/ldap/mdb/db' --delete /opt/zimbra 10.254.20.200::zimbra  >> $LOG 2>> $LOG

# Notify all connected users
su - zimbra  -c"zxsuite  chat broadcastMessage 'Coupure du Zimbra dans 1 min'" >> $LOG
sleep 60

before2="$(date +%s)"
VAR_START_HOUR=`/bin/date +%H:%M`

# Stop Zimbra Services
su - zimbra -c"/opt/zimbra/bin/zmcontrol stop" >> $LOG
sleep 15

# Kill any orphaned Zimbra processes
ORPHANED=`ps -u zimbra -o "pid="` && kill -9 $ORPHANED

# Sync to backup directory
rsync -avHK --stats --exclude 'data/ldap/mdb/db' --delete /opt/zimbra 10.254.20.200::zimbra >> $LOG 2>> $LOG
su - zimbra -c"rm -rf /home/tech/NFS/opt/zimbra/data/ldap/mdb/db/*"
su - zimbra -c"mdb_copy /opt/zimbra/data/ldap/mdb/db /home/tech/NFS/opt/zimbra/data/ldap/mdb/db"

VAR_RESULT=$?
VAR_TOTAL_NB=`$TAIL -15 $LOG | $GREP "Number of files: " | $CUT -d" " -f4`
VAR_TOTAL_SIZE=`$TAIL -15 $LOG | $GREP "Total file size: " | $CUT -d" " -f4`
VAR_TRANSFERT_NB=`$TAIL -15 $LOG | $GREP "Number of files transferred: " | $CUT -d" " -f5`
VAR_TRANSFERT_SIZE=`$TAIL -15 $LOG | $GREP "Total transferred file size: " | $CUT -d" " -f5`

VAR_STOP_HOUR=`$DATE +%H:%M`
VAR_DAY=`$DATE +%A_%d_%B_%Y`
VAR_OCC=`$DF -h | $GREP $($ECHO /opt | cut -f2 -d"/")`
VAR_OCC=`$ECHO $VAR_OCC | $CUT -d" " -f5`

$WGET -O /dev/null "http://www.bh-consulting.net/synchro.php?nom_client=$VAR_CLIENT&src=$VAR_SRCTITLE&type=$VAR_TYPE&date=$VAR_DAY&heuredebut=$VAR_START_HOUR&heurefin=$VAR_STOP_HOUR&status=$VAR_RESULT&nbfilestrans=$VAR_TRANSFERT_NB&tailletrans=$VAR_TRANSFERT_SIZE&nbfilestotal=$VAR_TOTAL_NB&tailletotal=$VAR_TOTAL_SIZE&use_disk=$VAR_OCC" > /dev/null 2> /dev/null

# Restart Zimbra Services
su - zimbra -c "/opt/zimbra/bin/zmcontrol start"  >> $LOG

# Calculates and outputs amount of time the server was down for
after="$(date +%s)"
elapsed="$(expr $after - $before2)"
hours=$(($elapsed / 3600))
elapsed=$(($elapsed - $hours * 3600))
minutes=$(($elapsed / 60))
seconds=$(($elapsed - $minutes * 60))
echo Server was down for: "$hours hours $minutes minutes $seconds seconds"  >> $LOG

# Display Zimbra services status
echo Displaying Zimbra services status...  >> $LOG
su - zimbra -c "/opt/zimbra/bin/zmcontrol status"  >> $LOG
 
# Outputs the time the backup finished
echo Time backup finished = $(date +%T)

# Calculates and outputs total time taken
after="$(date +%s)"
elapsed="$(expr $after - $before)"
hours=$(($elapsed / 3600))
elapsed=$(($elapsed - $hours * 3600))
minutes=$(($elapsed / 60))
seconds=$(($elapsed - $minutes * 60))
echo Time taken: "$hours hours $minutes minutes $seconds seconds"  >> $LOG
