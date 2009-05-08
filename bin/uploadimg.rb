#!/usr/bin/env ruby
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Thu Mar 26 16:17:47 2009 EST
#Description: 
require "rubygems"
require "mechanize"

host = "http://petaimg.com"

if __file__=$0
    img = ARGV[0]

    agent = WWW::Mechanize.new
    agent.max_history = 1
    agent.user_agent_alias= 'Windows IE 7'
    if host == "http://petaimg.com"
        page = agent.get(host)
        form = page.forms[0]
        form.file_upload('file[]').file_name=img
        form.button('submit').value='true'
        newpage = form.submit( form.button('submit') )
        #puts newpage.body
        puts newpage.links[5].href
    end
end
