#!/bin/bash
# vim:fdm=marker
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 为kindle起无线网络

if [[ $1 = 'start' ]]; then
    # source and target interfaces
    [[ -n $2 ]] && sint=$2 || sint=wlan0
    [[ -n $3 ]] && tint=$3 || tint=wlan1
    sudo ifconfig $tint 10.10.10.1 netmask 255.255.255.0
    sudo iptables -t nat -A POSTROUTING -o $sint -j MASQUERADE
    sudo systemctl start dhcpd4
    sudo systemctl start hostapd
elif [[ $1 == 'stop' ]]; then
    sudo systemctl stop hostapd
    sudo systemctl stop dhcpd4
else
    echo "Usage: $0 {start|stop} [SINTERFACE [TINTERFACE]]"
fi
