#!/usr/bin/zsh
#

TODO=~/doc/markdown/TODO.md
REMINDERS=~/.reminders
KMURL="kmtrigger://macro=111C13C8-7881-45CE-B476-142F7D2D286A&value="

if [ -f $REMINDERS ]; then
  stat -c %w $REMINDERS |grep -q `date +%Y-%m-%d` || rm $REMINDERS
fi
[ ! -f $REMINDERS ] && touch $REMINDERS

while read line;
do
  if ! grep -Fxq "$line" $REMINDERS ; then
    echo "$line"
    ssh zoidburg "open \"$KMURL$line\""
    echo "$line" >> $REMINDERS
  fi
done < <(cat $TODO|awk 'a && /^- @/ {print} /^## / && $2==strftime("%Y-%m-%d") {a=1} /^## / && $2 < strftime("%Y-%m-%d") { exit }' |sed 's/:/ /;s/^.\+@ \?//')
