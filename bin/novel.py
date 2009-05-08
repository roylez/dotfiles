#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Fri Mar 13 10:12:31 2009 EST
#Description: 
import urllib2, re, shelve, os, sys
try:
    import pysco
    pysco.full()
except:
    pass

ixxwids = [('卡徒','6507'),
        ('盘龙','4191'), 
        #('巫颂','74029'), 
        ('恶魔法则','150'),
        ('天王','10975'),
        ('蔚蓝轨迹','6530'),
        ('斗罗大陆','10072'),
        ('超级骷髅兵','405')]

def getLatestNovel(url, name, last):
    page = urllib2.urlopen(url).read().decode('gbk').encode('utf8')
    matches = re.findall('<a href="(\d+\.html)">(.*?)</a>', page)
    if last:
        lastindex = 0
        for item in matches:
            if item[0] == last:      break
            lastindex += 1
        if lastindex == len(matches)-1:      return []
        if lastindex > len(matches)-1:      return [matches[-1]]
        return matches[lastindex+1:]
    else:
        return matches

if __name__=="__main__":
    latest = shelve.open("%s/.backup/latestchap" %os.environ['HOME'])
    for item in ixxwids:
        url = "http://www.3jzw.com/files/article/html/%d/%s/index.html" \
                %(int(item[1])/1000, item[1]) 
        try:
            if latest.has_key(item[1]):
                alist = getLatestNovel(url, item[0], latest[item[1]])
                if alist:
                    latest[item[1]] = alist[-1][0]
                    print "\033[34;1m%s\033[m" %item[0]
                    for j in alist:
                        print "\t%s" %j[1]
                        print "\t%s" %url.replace("index.html", j[0])
            else:
                #rebuild the database if the links have been modified
                alist = getLatestNovel(url, item[0], None)
                latest[item[1]] = alist[-1][0]
        except:
            pass
