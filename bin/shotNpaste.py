#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Mon Mar 09 07:35:21 2009 EST
#Description: 
import os, time

img = "/tmp/shot%s.png" %time.strftime("%Y%m%d%H%M")
os.system("import %s" %img)
msg = os.popen("shag %s" %img).read().strip()
notifyargs = "notify-send -t 5000 -i ~/.icons/png-1009.png"
os.system("echo '%s'|xsel -i -b" %msg)
os.system("echo '%s'|xsel -i -p" %msg)
text = '<span size="14000" color="green" weight="bold">请直接粘贴到所需处</span>' 
os.system("%s 'Meoww~~, 贴图成功: ' '\n\n%s'" %(notifyargs,text))
