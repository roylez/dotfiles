#!/bin/bash
# vim:fdm=marker
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 
printer=$(dialog --stdout --menu "Select a printer:" 0 0 0 $(lpstat -v |awk '{print $3,$4}' |sed -r 's-^(.*?): (.*)$-\1 \2-'))
lpr -P $printer $*
