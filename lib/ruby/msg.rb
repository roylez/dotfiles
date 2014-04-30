#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Last Change: Wed 23 Feb 2011 08:42:58 PM CST
#Description: 用notify-send在桌面显示提醒

icon_path = File.join( ENV['HOME'], '.icons')
servants = Dir.glob(File.join(icon_path, 'servants', '*.png'))
$icon = servants[rand(servants.length)]
$title = '主人，提醒您一下：'

def msg(kwds={})
    kwds = { :dbus => false, icon:$icon, title:$title, text:$text, :replace => 1 }.merge(kwds)
    cmd_prefix = "DISPLAY=:0.0 XAUTHORITY=#{ENV['HOME']}/.Xauthority"
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

def audio_msg(sound_file, kwds={})
  system(%Q{mplayer -really-quiet '#{sound_file}' &})   if File.file? sound_file
  msg(kwds)
end

if __FILE__==$0
  require 'optparse'
  options = {}
  OptionParser.new { |opts|
    opts.banner = "Usage: #{$0} [options] MSG"
    options[:quiet] = false
    opts.on('-q','--quiet','Do not play notice sound') { options[:quiet] = true }
    opts.on('-i','--icon ICON', 'Select icon for notice') {|a| options[:icon] = a }
    opts.on('-t','--title TITLE', 'Specify a title') {|t| options[:title] = t }
  }.parse!

  notice_sound = "#{ENV['HOME']}/.sounds/N9_ringtone/Email 1.mp3"
  kwds = options.merge( :text => ARGV.join(" ")) 

  options[:quiet] ? msg(kwds) : audio_msg(notice_sound, kwds)
end
