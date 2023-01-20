#!/bin/bash
# vim:fdm=marker
#Description: 在mutt中选择打印机并打印
printer=$(dialog --stdout --title "Printing $*" --menu "Select a printer:" 0 0 0 $(lpstat -v |awk '{print $3,$4}' |sed -r 's-^(.*?): (.*)$-\1 \2-'))
[ ! -z $printer ] && lpr -P $printer $*
