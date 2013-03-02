#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Wed 23 Feb 2011 08:42:58 PM CST
#Description: 用notify-send在桌面显示提醒

icon_path = File.join( ENV['HOME'], '.icons')
servants = Dir.glob(File.join(icon_path, 'servants', '*.png'))
$icon = servants[rand(servants.length)]
$title = '主人，提醒您一下：'

case ARGV.length
when 1
    $text = ARGV[0]
when 2
    $title, $text = ARGV
when 3
    $icon = File.exist?(ARGV[0]) ? ARGV[0] : \
        File.exist?(File.join( icon_path , ARGV[0])) ? File.join(icon_path,ARGV[0]) : icon
    $title, $text = ARGV[1..-1]
else
    $title = '错误'
    $text  = '参数无效'
end

def msg(kwds={})
    kwds = { :dbus => false, icon:$icon, title:$title, text:$text, :replace => 1 }.merge(kwds)
    cmd_prefix = "DISPLAY=:0.0"
    unless kwds[:dbus]
      kwds[:text] = %Q{<span size="12000" weight="bold">\n#{kwds[:text]}</span>}
      system(%Q{#{cmd_prefix} notify-send -i #{kwds[:icon]} '#{kwds[:title]}' '#{kwds[:text]}'})
    else
      system(%Q{#{cmd_prefix} \
        dbus-send --type=method_call --dest='org.freedesktop.Notifications' /org/freedesktop/Notifications org.freedesktop.Notifications.Notify \
        string:"#{kwds[:application]}" \
        uint32:"#{kwds[:replace]}" \
        string:"#{kwds[:icon]}" \
        string:"#{kwds[:title]}" \
        string:"\n#{kwds[:text]}" \
        array:string:"#{kwds[:actions]}" \
        dict:string:string:'','' \ 
      })
    end
end

if __FILE__==$0
    msg
end
