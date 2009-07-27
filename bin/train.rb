#!/usr/bin/env ruby
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Mon Jul 27 20:07:28 2009 EST
#Description: 
require 'iconv'
require 'rubygems'
require 'mechanize'
agent = WWW::Mechanize.new
agent.max_history = 1
agent.user_agent_alias= 'Windows IE 7'
begin
    page = agent.get("http://qq.ip138.com/train/search2.asp")
rescue
    puts "Cannot connect to server."
    exit
end
form = page.form('byroute')
form.field('from').value=ARGV[0]
form.field('to').value=ARGV[1]
res = form.submit(form.button('Submit'))
msg = Iconv.conv('UTF-8//IGNORE','GBK//IGNORE', res.body)
if msg.index('能直达')
    l = []
    msg.scan(/<table.*?<\/table>/) { |t|
        lst = []
        t.scan(/htm"><b>(.*?)<(.*?)<tr/) { 
            no = $1[0..-4]
            info = $2.scan(/<td>(.*?)<\/td>/)
            lst << [no] + info.flatten
        }
        l << lst
    }
    banner = [" \e[34m#{ARGV[0]}\e[m \e[31m=>\e[m \e[34m#{ARGV[1]}\e[m ", 
            " \e[34m#{ARGV[1]}\e[m \e[31m=>\e[m \e[34m#{ARGV[0]}\e[m "]
    l.each_index { |i|
        puts ' ' + '='*30 + banner[i] + '='*30
        lst = l[i]
        w0 = lst.map{|x| x[0].size }.max
        w1 = lst.map{|x| x[1].size }.max
        w2 = lst.map{|x| x[2].size }.max
        w3 = lst.map{|x| x[3].size }.max
        w4 = lst.map{|x| x[4].size }.max
        w6 = lst.map{|x| x[6].size }.max
        quickest = lst.min{|x,y| 
            a = x[8].split('小时') 
            b = y[8].split('小时')
            a[0] = a[0].to_i
            b[0] = b[0].to_i
            a <=> b
        }
        lst.each {|x|
            puts "\e[33m%-#{w0}s\e[m" %x[0] + '  ' + 
                 "\e[36m#{x[1]}\e[m" + ' '*((w1-x[1].size)*2/3 + 2) + 
                 "\e[36m#{x[2]}\e[m" + ' '*((w2-x[2].size)*2/3 + 2) + 
                 x[3] + ' '*((w3-x[3].size)*2/3 + 2) + 
                 x[4] + ' '*((w4-x[4].size)*2/3 + 2) + x[5] + '  ' +
                 x[6] + ' '*((w6-x[6].size)*2/3 + 2) + x[7] + '  ' +
                 (quickest == x ? "\e[32;1m#{x[8]}\e[m" : x[8]) + '  ' + 
                 x[9..-1].join("  ")
        }
    }
end
