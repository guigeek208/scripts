#!/bin/bash
FILE="ListeZimbraMails.csv"
echo "" > $FILE

function getAliases {
    echo "get Aliases"
    ALIAS=0
    i=2
    while [[ $ALIAS != "" ]];
    do
        #echo $i
        ALIAS=`echo $ligne |cut -d"," -f$i`
        echo $ALIAS
        echo -n "$ALIAS," >> $FILE
        echo "zmprov aaa $EMAIL $ALIAS"
        i=$(($i+1))
    done
}

function randpw(){ < /dev/urandom tr -dc a-z0-9 | head -c${1:-6};echo;}


while read ligne
do
  #echo $ligne
  EMAIL=`echo $ligne |cut -d"," -f1`
  LOGIN=`echo $EMAIL |cut -d"@" -f1`
  echo -n "$EMAIL," >> $FILE  
  PASS=`randpw`
  echo -n "$PASS," >> $FILE 
  echo "zmprov ca $EMAIL $PASS"
  getAliases $ligne
  
  echo "" >> $FILE
done < zimbra.csv
