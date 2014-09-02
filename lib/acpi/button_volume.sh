#!/bin/bash
# vim:fdm=marker
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 

script_dir=/home/roylez/bin

export DISPLAY=:0

BUTTON_UP=VOLUP
BUTTON_DN=VOLDN
BUTTON_MUTE=MUTE

set $*
logger "ACPI: $1 $2 button pressed, processed by $0"

case $2 in 
    $BUTTON_UP)     # volume up
        su roylez -c "$script_dir/change_volume up"
        ;;
    $BUTTON_DN)     # volume down
        su roylez -c "$script_dir/change_volume down"
        ;;
    $BUTTON_MUTE)   # mute
        su roylez -c "$script_dir/change_volume toggle"
        ;;
esac


