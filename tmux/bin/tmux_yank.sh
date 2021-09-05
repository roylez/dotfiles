#!/bin/bash
# description: tmux yank integration
# https://medium.com/free-code-camp/tmux-in-practice-integration-with-system-clipboard-bcd72c62ff7b

set -eu
# get data either form stdin or from file
buf=$(cat "$@")
# Get buffer length
buflen=$( printf %s "$buf" | wc -c )
maxlen=74994
# warn if exceeds maxlen
if [ "$buflen" -gt "$maxlen" ]; then
   printf "input is %d bytes too long" "$(( buflen - maxlen ))" >&2
fi
# build up OSC 52 ANSI escape sequence for clipboard operation
esc="\e]52;c;$( printf %s "$buf" | head -c $maxlen | base64 | tr -d '\r\n' )\a"

pane_active_tty=$(tmux list-panes -F "#{pane_active} #{pane_tty}" | awk '$1=="1" { print $2 }')
# target_tty="${SSH_TTY:-$pane_active_tty}"

# if over ssh, sent to SSH_TTY otherwise pane tty
printf "\ePtmux;\e$esc\e\\" > $pane_active_tty
