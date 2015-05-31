#!/bin/bash
# vim:fdm=marker
# Description:
#

repo=~/workspace/new2email/

full_star="★"
void_star="☆"
commits=$(cd $repo; git log --pretty=oneline --since="00:00" --all|wc -l)

print_status() {
    char1=$1
    char2=$2
    c1=$3
    [[ -n $4 ]] && c2=$4 || c2=$((5-c1))
    if [[ -n c1 ]]; then
        for i in `seq 1 $c1`; do
            echo -n "$char1 "
        done
    fi
    if [[ -n $c2 ]]; then
        for i in `seq 1 $c2`; do
            echo -n "$char2 "
        done
    fi
}

case $commits in
    0 )         # print sys load as a fallback
        w | awk -F: 'NR==1 {print $NF}' |xargs ;;
    [1-4] )
        print_status $void_star " " $commits;;
    [5..10] )
        solid=$((commits-5))
        print_status $full_star $void_star $solid;;
    * )
        print_status $full_star ' ' 5;;
esac
