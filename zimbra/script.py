#!/usr/bin/python
# -*- coding: utf-8 -*-
import feedparser
import time
from datetime import date
import datetime
import os

boolERR = False
listERR = []
listLOG = []
URL = "https://backup:*****@x.x.x.x/home/backup/"

def createFile():
    f = file("/tmp/msg.log", "w")
    f.write("from: ***@bh-consulting.net\n")
    f.write("to: ***@bh-consulting.net\n")
    if (len(listERR)<=0):
        f.write("subject: [INFO] résumé des sauvegardes\n")        
    else:
        f.write("subject: [ERR] résumé des sauvegardes\n")
        f.write("Vérifiez les sauvegardes suivantes :\n")
    for e in listERR:
        f.write(e)

    f.write("\n\n")
    f.write("Résumé des sauvegardes :")
    for e in listLOG:
        f.write(e)

    return f

def parseRSS(directory,afterdate, delta,checklist):
    summary=[]
    d = feedparser.parse(URL+directory+'?fmt=rss&query=after:'+afterdate)
    today = date.today()
    deltadays = date.today() - datetime.timedelta(days=delta)
    
    
    for echeck in checklist:
        found=0
        Boolexpired=False
        for e in d['entries']:
            daterss = e.date_parsed
            fdate = date.fromtimestamp(time.mktime(daterss))     
            if (e.get('title', '').encode('utf-8') == echeck):
                Boolexpired=(today - fdate > datetime.timedelta(days=delta))
                found=1
                break
        if (found == 0 or Boolexpired): 
            boolERR=True     
            if (Boolexpired):
                deltasave = today - fdate
                print (echeck + " from "+str(deltasave))
            if (found == 0):
                listERR.append(echeck+"\n")
                listERR.append("Aucune notification depuis plus de "+str(delta)+" jours\n")
    
    listLOG.append ("\nRésumé des dernières sauvegardes pour "+directory+"\n")
    for e in d['entries']:
        daterss2 = e.date_parsed
        if (not isinstance(daterss2,str)):
            fdate = date.fromtimestamp(time.mktime(daterss2))            
            listLOG.append(str(fdate) + " " + e.get('title', '').encode('utf-8')+"\n")      
        
lastmonth = date.today() - datetime.timedelta(days=30)
afterdate = str(lastmonth.month)+"/"+str(lastmonth.day)+"/"+str(lastmonth.year)


checklist = []
checklist.append("SUBJECT")
parseRSS("Dossier", afterdate, 7, checklist)


f=createFile()
os.system("sendmail ***@bh-consulting.net < /tmp/msg.log")
