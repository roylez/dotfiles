#!/bin/bash

session_start() {
  nohup mpv --really-quiet --volume=90 http://192.168.0.100:6606 >/dev/null &
}

session_end() {
  pkill mpv
  exit 0
}

case "$1" in
  start)
    ( pgrep mpv &>/dev/null ) || session_start
    ;;
  end)
    session_end
    ;;
  *) 
    ( pgrep mpv &>/dev/null ) && session_end || session_start
    ;;
esac
