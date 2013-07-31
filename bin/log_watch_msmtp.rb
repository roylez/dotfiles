#!/usr/bin/env ruby
# vim:fdm=marker
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 检查最新的发送邮件结果

load '/home/roylez/bin/msg'

log = ARGV.first

string = `tail -n 1 #{log} |tac`

pat1 = /recipients=([^ ]*) .*? exitcode=(.*?)$/

extracts = []
status = nil
to = nil

string.each_line do |l|
  if l.strip =~ pat1
    status = $2
    to = $1
  end
end

msg :dbus => true, :title => "邮件: ", :text => "\n收件人: #{to}\n\n发送#{(status =~ /ex_ok/i) ? "成功" : "失败"}"
