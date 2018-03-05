#!/usr/bin/env zsh
#

cd $1

j=1 

for i in *.jpg(oN); do echo mv "$i" "$(printf '%03d' $j).jpg" &; ((j++)); done
