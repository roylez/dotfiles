#!/bin/bash
# vim:fdm=marker
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 
printer=$(dialog --stdout --title "Printing $*" --menu "Select a printer:" 0 0 0 $(lpstat -v |awk '{print $3,$4}' |sed -r 's-^(.*?): (.*)$-\1 \2-'))
[ ! -z $printer ] && lpr -P $printer $*
