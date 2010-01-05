#!/usr/bin/env ruby
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Fri 25 Dec 2009 12:38:47 PM EST
#Description: 
require "rubygems"
require "mechanize"

#host = "http://petaimg.com"
host = 'http://kimag.es'
#host = 'http://bayimg.com'

if __file__=$0
    img = ARGV[0]

    agent = WWW::Mechanize.new
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
        #page = agent.get(host)
        #form = page.forms[0]
        #form.file_upload('userfile1').file_name=img
        #newpage = form.submit form.buttons[0]
        newpage = agent.get(host).form_with(:method=>'POST') do |f|
            f.file_upload('userfile1').file_name = img
        end.submit
        puts newpage.links[6].href
    when 'http://bayimg.com'
        puts 'hello'
    end
end
