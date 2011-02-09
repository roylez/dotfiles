#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Sun 09 Jan 2011 04:53:20 PM CST
#Description: 

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
    kwds = { icon:$icon, title:$title, text:$text }.merge(kwds)
    kwds[:text] = %Q{<span size="12000" weight="bold">\n#{kwds[:text]}</span>}
    system(%Q{DISPLAY=:0.0 notify-send -i #{kwds[:icon]} '#{kwds[:title]}' '#{kwds[:text]}'})
end

if __FILE__==$0
    msg
end
