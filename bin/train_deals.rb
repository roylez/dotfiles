#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 

require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'yaml'

def get_last_deal(*target_cities) 
    threads = [ ]
    target_cities.collect do |city|
        threads << Thread.new do 
            url = "http://shanghai.baixing.com/huochepiao/?发车日期=&车次=&出发城市=上海&到达城市=#{city}"
            page = Nokogiri::HTML(open(URI.escape url))
            res = page.xpath("//table[@id='huochepiaoListing']//tr")
            rows = res[1..-1].select{|tr| (tr / 'td[last()]').first and (tr / 'td[last()]').first.text =~ /\d+分钟前|刚刚/ } 
            rows = rows || res[1]
            rows.collect do |row|
                u = "http://shanghai.baixing.com" + (row / 'td/a').first.attr("href")
                a = (row / 'td/a').first.text 
                t = (row / 'td[last()]').first.text
                newp = open(u).read.force_encoding("UTF-8")
                phone = newp[/联系方式.*?<span[^>]*>(\d+)</m, 1]
                a = t << " " << a << " #{phone}"
                [ u , a ]
            end
        end
    end
    threads.each{|t| t.join}
    threads.inject([]){|s, t| s += t.value}
end

if __FILE__ == $0
    dbfile = File.join(ENV['HOME'],'.backup','latest_train.yml')

    latest = ((!File.exists?(dbfile) || File.zero?(dbfile)) ? [] : YAML.load_file(dbfile))

    current = get_last_deal(*ARGV)

    current.each do |url, info|
        next    if latest.include? url
        puts info
        latest << url
    end

    open(dbfile,'w') { |f| f.puts latest.to_yaml }
end
