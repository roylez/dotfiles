#!/bin/zsh

# completion
#
# Follow GNU LS_COLORS for completion menus
zmodload -i zsh/complist

if [[ "$TERM" == xterm* ]] || [[ "$TERM" = screen ]]; then
    #use prefefined colors
    eval $(dircolors -b $HOME/.lscolor256)
else
    eval $(dircolors -b $HOME/.lscolor)
fi

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*' list-colors '=%*=01;31' 
#ignore list in completion
zstyle ':completion:*' ignore-parents parent pwd directory
#menu selection in completion
zstyle ':completion:*' menu select=1
#correction in completion
#zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' completer _complete _match 
zstyle ':completion:*:match:*' original only 
zstyle ':completion:*:approximate:*' max-errors 1 numeric 
## case-insensitive (uppercase from lowercase) completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
### case-insensitive (all) completion
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
#kill completion
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER' 
#use cache to speed up pacman completion
zstyle ':completion::complete:*' use-cache on
#zstyle ':completion::complete:*' cache-path .zcache 
#group matches and descriptions
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d --\e[0m' 
zstyle ':completion:*:messages' format $'\e[01;35m -- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m' 

#autoload -U compinit
autoload -Uz compinit
compinit

#remove / and . from WORDCHARS to allow alt-backspace to delete word
local WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

#autoload -U tetris

setopt complete_aliases     #do not expand aliases _before_ completion has finished
setopt auto_cd              # if not a command, try to cd to it.
setopt auto_pushd            # automatically pushd directories on dirstack
setopt pushd_ignore_dups      # do not push dups on stack
setopt pushd_silent          # be quiet about pushds and popds
setopt brace_ccl            # expand alphabetic brace expressions
#setopt chase_links          # ~/ln -> /; cd ln; pwd -> /
setopt complete_in_word     # stays where it is and completion is done from both ends
setopt correct              # spell check for commands only
#setopt equals extended_glob # use extra globbing operators
setopt hash_list_all        # search all paths before command completion
setopt hist_ignore_all_dups     # when runing a command several times, only store one
setopt hist_reduce_blanks   # reduce whitespace in history
setopt share_history        # share history among sessions
setopt hist_verify       # reload full command when runing from history
setopt hist_expire_dups_first  #remove dups when max size reached
setopt interactive_comments # why not?
setopt list_types           # show ls -F style marks in file completion
setopt numeric_glob_sort    # when globbing numbered files, use real counting
setopt inc_append_history   # append to history once executed

# prompt
autoload -U promptinit zmv
promptinit
if [ "$SSH_TTY" = "" ]; then
    host="%B%F{magenta}%m%f%b"
else
    host="%B%F{red}%m%f%b"
fi
user="%B%(!:%F{red}:%F{green})%n%f%b"       #different color for privileged sessions
symbol="%B%(!:%F{red}# :%F{yellow}> )%f%b"
job="%1(j,%F{red}:%F{blue}%j,)%f%b"
export PROMPT=$user"%F{yellow}@%f"$host$job$symbol
#export RPROMPT="%{$fg_no_bold[${1:-magenta}]%}%~%{$reset_color%}"
export RPROMPT="%F{magenta}%~%f"

# history
# number of lines kept in history
export HISTSIZE=10000
# number of lines saved in the history after logout
export SAVEHIST=10000
# location of history
export HISTFILE=$HOME/.zsh_history

# alias and listing colors
if [ "$TERM" != "dumb" ]; then
    #enable ls and grep color and sort by extension
    #alias vi='vim'
    export GREP_COLOR='31;1'
    alias grep='grep -I --color=always'
    alias egrep='egrep -I --color=always'
    alias cal='cal -3m'
    alias ls='ls -h --color=auto -X --time-style="+[33m[[32m%y-%m-%d [35m%k:%M[33m][m"'
    alias vi='vim'
    alias ll='ls -l'
    alias df='df -Th'
    alias du='du -h'
    #show directories size
    alias dud='du -s *(/)'
    #alias which='alias | /usr/bin/which --read-alias'
    alias pyprof='python -m cProfile'
    alias history='history 1'       #zsh specific
    #alias mplayer='mplayer -cache 512'
    alias zhcon='zhcon --utf8'
    alias vless="/usr/share/vim/macros/less.sh"
    del() {mv -vif -- $* ~/.Trash}
    alias m='mutt'
    alias port='netstat -ntlp'      #opening ports
    alias e264='mencoder -vf harddup -ovc x264 -x264encopts crf=22:subme=5:frameref=2:8x8dct:bframes=3:weight_b:b_pyramid -oac mp3lame -lameopts aq=7:mode=0:vol=1.2:vbr=2:q=6 -srate 32000'
    alias tree="tree --dirsfirst"
    alias top10='print -l  ${(o)history%% *} | uniq -c | sort -nr | head -n 10'
    #alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
    alias tt="vim +'set spell' ~/doc/TODO.otl"
    alias mlychee="sshfs -p 2023 roy@lychee: /home/roylez/remote/lychee"
    #alias rtm="twitter d rtm"
    alias rtorrent="screen rtorrent"
    alias pal="pal --color"
    256tab() 
    {
        for k in `seq 0 1`;do 
            for j in `seq $((16+k*18)) 36 $((196+k*18))`;do 
                for i in `seq $j $((j+17))`; do 
                    printf "\e[01;$1;38;5;%sm%4s" $i $i;
                done;echo;
            done;
        done
    }
    if [ '$HOSTNAME' != 'lychee' ]; then
        for i in showq qstat qdel qnodes showstart; do 
            alias $i="ssh roy@lychee -p 2023 /opt/bin/$i"
        done
        function qsub(){ssh roy@lychee -p 2023 "cd ${(S)PWD#lez/remote/lychee};/opt/bin/qsub -o /tmp -e /tmp $1"}
    fi
    if [ -x /usr/bin/grc ]; then
        alias cl="/usr/bin/grc -es --colour=auto"
        for i in diff cat make gcc g++ as gas ld netstat ping traceroute; do
            alias $i="cl $i"
        done
    fi
    alias -g A="|awk"
    alias -g E="|sed"
    alias -g G="|grep"
    alias -g L="|less"
    alias -g S="|sort"
    alias -g X="|xargs"
    alias -g C="|wc"
fi

# active command as title in terminals
case $TERM in
    xterm*|rxvt*)
    function title() 
    { 
        #print -nP '\e]0;'$*'\a'
        print -nPR $'\033]0;'$1$'\a'
    } ;;
    screen*)
    function title() 
    {
        #modify screen title
        print -nPR $'\033k'$1$'\033'\\
        #modify window title bar
        #print -nPR $'\033]0;'$2$'\a'
    } ;;
    *) 
    function title() {}
    ;;
esac     

#set screen title if not connected remotely
#if [ "$STY" != "" ]; then
function precmd {
    #title "`print -Pn "%~" | sed "s:\([~/][^/]*\)/.*/:\1...:"`" "$TERM $PWD"
    title "`print -Pn "%~" |sed "s:\([~/][^/]*\)/.*/:\1...:;s:\([^-]*-[^-]*\)-.*:\1:"`" "$TERM $PWD"
    echo -ne '\033[?17;0;127c'
}

function preexec {
    emulate -L zsh
    local -a cmd; cmd=(${(z)1})
    if [[ $cmd[1]:t == "ssh" ]]; then
        title "@""`echo $cmd[2]|sed 's:.*@::'`" "$TERM $cmd"
    elif [[ $cmd[1]:t == "sudo" ]]; then
        title "#"$cmd[2]:t "$TERM $cmd[3,-1]"
    elif [[ $cmd[1]:t == "for" ]]; then
        title "()"$cmd[7] "$TERM $cmd"
    elif [[ $cmd[1]:t == "svn" ]]; then
        title "$cmd[1,2]" "$TERM $cmd"
    elif [[ $cmd[1]:t == "ls" ]] || [[ $cmd[1]:t == "ll" ]] ; then
    else
        title $cmd[1]:t "$TERM $cmd[2,-1]"
    fi 
}
#fi 

#bindkey "\M-v" "\`xclip -o\`\M-\C-e\""
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
autoload -U zkbd
bindkey -e      #use emacs style keybindings :(
typeset -A key  #define an array

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char
bindkey "p" history-beginning-search-backward
bindkey "n" history-beginning-search-forward

#-----------------user defined widgets---------------------------------
#from linuxtoy.org: 
#   pressing TAB in an empty command makes a cd command with completion list
dumb-cd(){
    if [[ -n $BUFFER ]] ; then # 如果该行有内容
        zle expand-or-complete # 执行 TAB 原来的功能
    else # 如果没有
        BUFFER="cd " # 填入 cd（空格）
        zle end-of-line # 这时光标在行首，移动到行末
        zle expand-or-complete # 执行 TAB 原来的功能
    fi 
}
zle -N dumb-cd
bindkey "\t" dumb-cd #将上面的功能绑定到 TAB 键

#----------------------exports-----------------------------------------
export PATH=$HOME/bin:$PATH:$HOME/.gem/ruby/1.8/bin
export EDITOR=vim
export VISUAL=vim

#MOST like colored man pages
export LESS_TERMCAP_md=$'\E[1;31m'      #bold1
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_me=$'\E[m'
export LESS_TERMCAP_so=$'\E[01;44;33m'  #search highlight
export LESS_TERMCAP_se=$'\E[m'
export LESS_TERMCAP_us=$'\E[1;2;32m'    #bold2
export LESS_TERMCAP_ue=$'\E[m'
export LESS="-M -i -R --shift 5"
#export LESSOPEN="|lesspipe.sh %s"       #lesspipe

#for ConTeX
#source $HOME/.context_env /home/roylez/soft/ConTeXt/tex

#for gnuplot
export GDFONTPATH=$(dirname `locate DejaVuSans.ttf | tail -1`)

#for intel fortran compiler
#source $HOME/soft/intel/ifort/bin/ifortvars.sh

#for slrn
#export NNTPSERVER=news.newsfan.net 
