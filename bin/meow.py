#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Thu Apr 16 08:11:47 2009 EST
#Description: various actions to perform on selected text

import os, re, urllib, urllib2, sys, random

string = (sys.argv[1] if len(sys.argv)==2 else (os.popen('xsel -o').read().strip()))

icons = ['png-0901.png', 'png-0902.png', 'png-0903.png', 'png-0904.png', 'png-0905.png', 'png-0906.png', 'png-0907.png', 'png-0908.png', 'png-1009.png'] 
iconno = random.randint(0,len(icons)-1)
notifyargs = "notify-send -t 5000 -i ~/.icons/%s" %icons[iconno]
if string.isalpha():
    #单词翻译
    translation = os.popen('sdcv -u 朗道英汉字典5.0 -n "%s"' %string).readlines()
    #translation = os.popen('sdcv -u WordNet -n "%s"' %string).readlines()
    for line in translation[:]:
        translation.pop(0)
        if re.match("^-->%s$" %string, line, re.IGNORECASE):
            break
    if translation != []:
        translation = ''.join(translation)
        os.system('%s "%s的意思是：" "%s"' %(notifyargs, string,translation) )
        os.system('espeak %s' %string)
    else:
        text = '<span size="13000" color="brown" weight="bold">%s</span>' \
            %('\n\n  '+ '没有查到%s这个词' %string )
        os.system("%s '很抱歉：' '%s'" %(notifyargs, text) )
elif re.match("^(\d{1,3}\.){3}\d{1,3}$", string):
    #ip查询
    #eform = urllib.urlencode({"ip":string, "action":2})
    eform = urllib.urlencode({'B1':'查询'.decode('utf8').encode('gb2312'),'job':'search',
        'search_ip':string})
    #request = urllib2.Request("http://www.ip138.com/ips.asp", eform) 
    request = urllib2.Request('http://ipseeker.cn/index.php', eform) 
    page = urllib2.urlopen(request).read()
    address = page.decode("gb2312").encode("utf8")
    #address = re.search('本站主数据：(.*?)</li', address, re.DOTALL).group(1)
    address = re.search('查询结果二.*%s.*?-&nbsp;\s+(.*?)</span' %string,address).group(1)
    text = '<span size="13000" color="red" weight="bold">%s</span>' \
            %('\n'+ address.replace(" ", "\n\n\t") )
    os.system("%s '%s地址在：' '%s'" %(notifyargs,string,text) )
elif re.match("^1(\d){10}$", string):
    #手机号归属地与运营商查询
    data = urllib.urlencode({"mobile": string, "step": 2})
    page = urllib.urlopen("http://flash.chinaren.com/ip/mobile.php",
        data ).read().decode('gbk').encode('utf-8')
    result = re.findall("tdc2>(.*?)</TD>", page)
    text = '<span size="13000" color="red" weight="bold">%s</span>' \
            %('\n'+result[1].replace('&nbsp;', '')+'\n\n'+result[2])
    os.system("%s '%s机主在：' '%s'" %(notifyargs,string,text))
elif re.match("(https?|ftp)://[\-\.\,/%~_:?\#a-zA-Z0-9=&\;]+", string):
    #打开url
    os.system("$HOME/bin/firefox '%s' &" %string)
elif string=="":
    text = '<span size="13000" color="red" weight="bold">%s</span>' \
            %('\n'+ 'Thou must give me a command!')
    os.system("%s '咦？' '%s'" %(notifyargs,text) )
