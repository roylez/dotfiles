#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 粘贴一段文字到 pastbin.com
require 'rubygems'
require 'mechanize'

$paste_bin = {
  :pastebin => {
    :url => 'http://pastebin.com',
    :code => 'paste_code' , 
    :edit_url => 'http://pastebin.com/index',
    :opts => { 'paste_expire_date' => '1M' },
  },
}

class PasteBin
  attr_reader :bin, :agent

  def push(text)
    get_agent unless @bin
    edit(@bin_detail[:url], text)
  end

  def pull(id)
    get_agent unless @bin
    @agent.get(@bin_detail[:url] + '/' + id).form_with(:method => 'POST').field(@bin_detail[:code]).value
  end

  def append(id, text)
    get_agent unless @bin
    edit(@bin_detail[:edit_url] + '/' + id){ |v| v << '\n' << text }
  end

  def edit(url, text = nil)
    get_agent unless @bin
    @agent.get(url).form_with(:method => 'POST') do |f|
      text ||= f.field(@bin_detail[:code]).value
      text = yield text   if block_given?
      f.field(@bin_detail[:code]).value = text

      @bin_detail[:opts].each do |field, value|
        f.field(field).value = value
      end   if @bin_detail[:opts]
    end.submit.uri
  end

  private
  def get_agent(*bins)
    @agent = Mechanize.new
    @agent.max_history = 1
    @agent.user_agent_alias= 'Windows IE 7'
    @bin = :pastebin
    @bin_detail = $paste_bin[@bin]
  end
end

if __FILE__ == $0
  text = ARGV.join(' ')
  text = ARGF.read  rescue text
  puts PasteBin.new.push(text)
end
