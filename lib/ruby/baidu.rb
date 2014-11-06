#!/usr/bin/env ruby
# coding: utf-8
#Description:
require 'open-uri'
require 'net/http'
require 'uri'
require 'json'

BAIDU_KEY = '96dacf57ce5f242ec995d55c641efb16'

def parse_baidu_api_result(string)
  res = JSON.parse(string,
                   #:quirks_mode => true,
                   :symbolize_names => true,
                  )
  res[:status] == 'OK' ? res[:results] || res[:result] : nil
end

def geocoding(str)
  url = "http://api.map.baidu.com/geocoder?output=json&key=#{BAIDU_KEY}&address=" + str
  parse_baidu_api_result(open(URI.escape url).read)
rescue
  nil
end

# baidu place of interest search
#   :location => [lat, lng].join(',')
#   :raidus   => meters
#   :query    => interesting stuff to look for
#
def poi(params = {})
  params = {
    :src        => 'testapp',
    :radius     => 1000,
    :output     => :json,
    :ak         => BAIDU_KEY,
  }.merge params
  uri = URI("http://api.map.baidu.com/place/search")
  uri.query = URI.encode_www_form(params)

  res = Net::HTTP.get_response(uri)

  parse_baidu_api_result(res.body)
end

if __FILE__ == $0
  #p baidu_map_query( ARGV.join(" ") )
  p poi( :location => '30.48430473061,114.45158076795', :query => '公交站')
  #p geocoding('上海')
end
