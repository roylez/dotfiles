#!/bin/bash
#

var=$1

read -r -d '' theAppleScript <<EOF
   tell application "Keyboard Maestro Engine"
      tell variable "$var"
         if it exists then
            return its value
         else
            return "Error → Keyboard Maestro variable “$1” does not exist!"
         end if
      end tell
   end tell
EOF

osascript -e "$theAppleScript"
