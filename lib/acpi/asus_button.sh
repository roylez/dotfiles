#!/bin/bash
# vim:fdm=marker
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 

script_dir=/home/roylez/bin

export DISPLAY=:0

set $*

# "hotkey ATKD 00000030 ...."
if [[ $2 = ATK* ]]; then
    case $3 in
        00000032)   # mute
            su roylez -c "$script_dir/change_volume toggle"
            ;;
        00000031)   # volume down
            su roylez -c "$script_dir/change_volume down"
            ;;
        00000030)   # volume up
            su roylez -c "$script_dir/change_volume up"
            ;;
        0000005c)
            # suspend-hybrid
            #pm-suspend-hybrid &
            # swiss knife program, must be wrapped by rvm first
            #
            #   rvm wrapper ruby-1.9.2-head 1.9.2 meow.rb
            #
            su roylez -c "/home/roylez/.rvm/bin/1.9.2_meow.rb" 2>&1
            ;;
    esac
fi
