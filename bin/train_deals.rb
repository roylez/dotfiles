#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 

require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'yaml'
require 'email_msg'

def get_last_deal(*target_cities) 
  threads = [ ]
  target_cities.collect do |city|
    threads << Thread.new do 
      url = "http://shanghai.baixing.com/huochepiao/?发车日期=&车次=&出发城市=上海&到达城市=#{city}"
      page = Nokogiri::HTML(open(URI.escape url).read)
      res = page.xpath("//ol[@id='listingHead']//li")
      rows = res[1..-1].select{|li| (li / 'a').first and (li / 'a').attr('href') !~ /http/ and li.child.text =~ /\d+分钟前|刚刚/ } 
      rows = rows || res[1]
      rows.collect do |row|
        u = "http://shanghai.baixing.com" + (row / 'a').first.attr("href")
        a = row.child.text
        t = (row / 'a').first.text
        a = t.strip << " " << a.strip
        [u.strip, a]
      end
    end
  end
  threads.each{|t| t.join}
  threads.inject([]){|s, t| s += t.value}
end

if __FILE__ == $0
  dbfile = File.join(ENV['HOME'],'.backup','latest_train.yml')

  latest = ((!File.exists?(dbfile) || File.zero?(dbfile)) ? [] : YAML.load_file(dbfile))

  cities = ARGV.empty? ? ['武昌', '汉口', '武汉'] : ARGV

  current = get_last_deal(*cities)

  current.each do |url, info|
    next    if latest.include? url
    puts url + "\t" + info
    email_message("roylez@139.com", url + "\t" + info)
    latest << url
  end

  open(dbfile,'w') { |f| f.puts latest.to_yaml }

end
