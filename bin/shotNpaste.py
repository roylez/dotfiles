#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 
import os, time, shutil

img = "/tmp/shot%s.png" %time.strftime("%Y%m%d%H%M")
os.system("import %s" %img)
#os.system("scrot -s %s" %img)
#msg = os.popen("shag %s" %img).read().strip()
#msg = os.popen("/home/roylez/bin/uploadimg.rb %s" %img).read().strip()
msg = 'http://dl.getdropbox.com/u/243979/screenshot/' + img.split('/')[-1]
shutil.copy(img,
        os.path.join(os.environ['HOME'],'remote/Dropbox/Public/screenshot',img.split('/')[-1]))
print msg
notifyargs = "notify-send -t 5000 -i ~/.icons/servants/png-1009.png"
#os.system("echo '%s'|xclip -i -selection primary" %msg)
#os.system("echo '%s'|xclip -i -selection clipboard" %msg)
os.system("echo '%s'|xsel -i -p" %msg)
os.system("echo '%s'|xsel -i -b" %msg)
text = '<span size="14000" color="green" weight="bold">请直接粘贴到所需处</span>' 
os.system("%s 'Meoww~~, 贴图成功: ' '\n\n%s'" %(notifyargs,text))
