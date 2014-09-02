#!/usr/bin/env ruby
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 上传图片到网络并返回链接
require "rubygems"
require "mechanize"

$image_bins = {
    #:bkup => {
        #:url => 'http://bkup.co',
        #:img_field => 'file1',
        #:extractor => proc{|page| page.uri.to_s }
    #}
    :ubuntu_paste => {
        :url => 'http://paste.ubuntu.org.cn',
        :img_field => 'screenshot',
        :form_with => { :name => 'editor' },
        :extractor => proc{|page| page.uri.to_s }
    }
}

def upload_img_to_bin(file)
    hostname = $image_bins.keys.sample
    return nil  unless hostname
    host = $image_bins.delete hostname
    agent = Mechanize.new
    agent.max_history = 1
    agent.user_agent_alias= 'Windows IE 7'
    newpage = agent.get(host[:url]).form_with(host[:form_with] || {:method => 'POST'}) do |f|
        f.file_upload(host[:img_field]).file_name = file
    end.submit
    host[:extractor].call newpage
rescue
    retry
end

if __file__=$0
    img = ARGV[0]

    puts upload_img_to_bin( img )
end
