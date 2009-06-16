#!/usr/bin/env ruby
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Mon Jun 15 13:09:25 2009 EST
#Description: 
require 'net/http'
require 'uri'
require 'iconv'

from = '布里斯本'
to  = '武漢'
url = "http://www.digitaltravel.com.au/chinese/promotion.asp?sel=%A5%AC%A8%BD%B4%B5%A5%BB&sel_1=%AAZ%BA~"
page = Net::HTTP.get(URI.parse(url))
#p page
match = page.scan(/top>\s+<TD align=middle>(.*?)(<\/TD>\s+<TD align=middle>)(.*?)\2(.*?)\2(?:.*?)\2(.*?)\2(.*?)<\/TD>\s+<TD align=left>/m)
match.each { |m| puts Iconv.iconv('utf8//ignore', 'big5//ignore', m.values_at(0,2..-1).join("\t  ") )}
