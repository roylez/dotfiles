#!/usr/bin/env ruby
#
#
require 'yaml'
require 'net/http'
require 'uri'
require 'iconv'

dbfile = File.join(ENV['HOME'],'.backup','latest.yml')
bookid = {'6507'=>'卡徒',
        '4191'=>'盘龙', 
        '150'=>'恶魔法则',
        '10975'=>'天王',
        '6530'=>'蔚蓝轨迹',
        '10072'=>'斗罗大陆',
        '405'=>'超级骷髅兵'}

def getLatestNovel(url)
    page = Net::HTTP.get(URI.parse(url))
    page = Iconv.iconv('utf8','gbk',page).join
    matches = page.scan(/<a href="(\d+\.html)">(.*?)<\/a>/)
    return matches
end

if __FILE__==$0
    Thread.abort_on_exception = true
    threads = []
    alist = {}
    url0 = "http://www.3jzw.com/files/article/html/%d/%s/"
    bookid.each_key do |key|
        threads << Thread.new { 
            url =  url0 % [key.to_i/1000, key] + "index.html"
            begin
                alist[key] = getLatestNovel(url) 
            rescue
                exit
            end
        }
    end
    threads.each {|t| t.join}

    #f = File.open(dbfile,'r+')
    latest = (File.zero?(dbfile) ? {} : YAML.load_file(dbfile))
    alist.each_key do |key|
        if latest.key?( key )
            #屏幕输出更新
            oldi = alist[key].find_index {|x| x[0] == latest[key] }
            if oldi != nil and oldi < alist[key].length - 1
                puts "\e[34;1m#{bookid[key]}\e[m"
                alist[key][oldi+1..-1].each { |item| 
                    puts "\t#{item[1]}"
                    puts "\t%s" % (url0 % [key.to_i/1000,key] + item[0]) 
                }
            elsif oldi == nil 
                puts "\e[34;1m#{bookid[key]}\e[m has been updated!"
            end
        end
        #初始化数据库
        latest[key] = alist[key][-1][0]
    end
    open(dbfile,'w') { |f| f.puts latest.to_yaml }
end
