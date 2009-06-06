#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Sat Jun 06 12:55:34 2009 EST
#Description: 
import os, time

img = "/tmp/shot%s.png" %time.strftime("%Y%m%d%H%M")
os.system("import %s" %img)
#msg = os.popen("shag %s" %img).read().strip()
msg = os.popen("/home/roylez/bin/uploadimg.rb %s" %img).read().strip()
print msg
notifyargs = "notify-send -t 5000 -i ~/.icons/servants/png-1009.png"
#os.system("echo '%s'|xclip -i -selection primary" %msg)
#os.system("echo '%s'|xclip -i -selection clipboard" %msg)
os.system("echo '%s'|xsel -i -p" %msg)
os.system("echo '%s'|xsel -i -b" %msg)
text = '<span size="14000" color="green" weight="bold">请直接粘贴到所需处</span>' 
os.system("%s 'Meoww~~, 贴图成功: ' '\n\n%s'" %(notifyargs,text))
