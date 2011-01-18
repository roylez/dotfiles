#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 

require 'open-uri'
require 'nokogiri'

def get_last_deal(*target_cities) 
    target_cities.each do |city|
        url = "http://shanghai.baixing.com/huochepiao/?发车日期=&车次=&出发城市=上海&到达城市=#{city}"
        page = Nokogiri::HTML(open(URI.escape url))
        res = page.xpath("//table[@id='huochepiaoListing']//tr")[1]
        p res
        ret = {}
        {
            :add => '//td[1]', 
            :date => '//td[2]',
        }.each do |key, xpath|
            ret[key] = res.at_xpath(xpath).to_s.strip
        end
        p ret
    end
end

if __FILE__ == $0
    get_last_deal(*ARGV)
end
