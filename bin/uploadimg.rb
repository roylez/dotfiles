#!/usr/bin/env ruby
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 
require "rubygems"
require "mechanize"

#host = "http://petaimg.com"
#host = 'http://kimag.es'
host = 'http://imm.io'

if __file__=$0
    img = ARGV[0]

    agent = Mechanize.new
    agent.max_history = 1
    agent.user_agent_alias= 'Windows IE 7'
    case host
    when "http://petaimg.com"
        page = agent.get(host)
        form = page.forms[0]
        form.file_upload('file[]').file_name=img
        form.field('submit').value='true'
        newpage = form.submit
        #puts newpage.body
        puts newpage.links[5].href
    when 'http://kimag.es'
        newpage = agent.get(host).form_with(:method=>'POST') do |f|
            f.file_upload('userfile1').file_name = img
        end.submit
        puts (newpage / "input[@name='link']").last['value']
    when 'http://www.hostanypic.com/'
        newpage = agent.get(host).form_with(:method=>'POST') do |f|
            f.file_upload('uploads_0').file_name = img
        end.submit
        newpage = agent.get(newpage.links[0].href)
        puts (newpage/"textarea[@name='textarea{4}1']").first.inner_text.gsub(/\[.*?\]/,'')
    when 'http://imm.io'
        newpage = agent.get(host).form_with(:method=>'POST') do |f|
            f.file_upload('image').file_name = img
        end.submit
        puts newpage.uri.to_s.sub('imm', 'i.imm') + '.' + img.split('.').last
    end
end
