#!/bin/zsh
# vim:fdm=marker
#Last Change: Sat 24 Oct 2009 11:16:56 AM EST

#{{{------------------------listing color----------------------------------
autoload colors 
[[ $terminfo[colors] -ge 8 ]] && colors
if [[ "$TERM" = *256color ]] || [[ "$TERM" = screen ]]; then
    #use prefefined colors
    eval $(dircolors -b $HOME/.lscolor256)
else
    eval $(dircolors -b $HOME/.lscolor)
fi
#}}}

# {{{---------------------------options-------------------------------------
setopt complete_aliases         #do not expand aliases _before_ completion has finished
setopt auto_cd                  # if not a command, try to cd to it.
setopt auto_pushd               # automatically pushd directories on dirstack
setopt auto_continue            #automatically send SIGCON to disowned jobs
setopt pushd_ignore_dups        # do not push dups on stack
setopt pushd_silent             # be quiet about pushds and popds
setopt brace_ccl                # expand alphabetic brace expressions
#setopt chase_links             # ~/ln -> /; cd ln; pwd -> /
setopt complete_in_word         # stays where it is and completion is done from both ends
setopt correct                  # spell check for commands only
#setopt equals extended_glob    # use extra globbing operators
setopt no_hist_beep             # don not beep on history expansion errors
setopt hash_list_all            # search all paths before command completion
setopt hist_ignore_all_dups     # when runing a command several times, only store one
setopt hist_reduce_blanks       # reduce whitespace in history
setopt share_history            # share history among sessions
setopt hist_verify              # reload full command when runing from history
setopt hist_expire_dups_first   #remove dups when max size reached
setopt interactive_comments     # comments in history
setopt list_types               # show ls -F style marks in file completion
setopt long_list_jobs           # show pid in bg job list
setopt numeric_glob_sort        # when globbing numbered files, use real counting
setopt inc_append_history       # append to history once executed
setopt prompt_subst             # prompt more dynamic

#remove / and . from WORDCHARS to allow alt-backspace to delete word
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

#report to me when people login/logout
watch=(notme)
#replace the default beep with a message
#ZBEEP="\e[?5h\e[?5l"        # visual beep

#is-at-least 4.3.0 && 
# }}}

# {{{-------------------------completion system-----------------------------
zmodload -i zsh/complist
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*' list-colors '=%*=01;31' 
#ignore list in completion
zstyle ':completion:*' ignore-parents parent pwd directory
#menu selection in completion
zstyle ':completion:*' menu select=1
#zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' completer _complete _match _user_expand
zstyle ':completion:*:match:*' original only 
zstyle ':completion:*' user-expand _pinyin
zstyle ':completion:*:approximate:*' max-errors 1 numeric 
## case-insensitive (uppercase from lowercase) completion
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
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
zstyle ':completion:*:descriptions' format $'\e[33m == \e[1;46;33m %d \e[m\e[33m ==\e[m' 
zstyle ':completion:*:messages' format $'\e[33m == \e[1;46;33m %d \e[m\e[0;33m ==\e[m'
zstyle ':completion:*:warnings' format $'\e[33m == \e[1;47;31m No Matches Found \e[m\e[0;33m ==\e[m' 
zstyle ':completion:*:corrections' format $'\e[33m == \e[1;47;31m %d (errors: %e) \e[m\e[0;33m ==\e[m'

#autoload -U compinit
autoload -Uz compinit
compinit

# }}}

#{{{---------------------------history-------------------------------------
# number of lines kept in history
export HISTSIZE=10000
# number of lines saved in the history after logout
export SAVEHIST=10000
# location of history
export HISTFILE=$HOME/.zsh_history

#}}}

#{{{---------------------------alias---------------------------------------
# alias and listing colors
alias -g A="|awk"
alias -g C="|wc"
alias -g E="|sed"
alias -g G="|grep"
alias -g H="|head"
alias -g L="|less"
alias -g R="|tac"
alias -g S="|sort"
alias -g T="|tail"
alias -g X="|xargs"
alias -g N="> /dev/null"

#file types
[[ -x /usr/bin/apvlv ]] && alias -s pdf=apvlv
alias -s ps=gv
for i in jpg png;           alias -s $i=gqview
for i in avi rmvb wmv;      alias -s $i=mplayer
for i in rar zip 7z lzma;   alias -s $i="7z x"

export GREP_COLOR='31;1'
#no correct for mkdir mv and cp
for i in mkdir mv cp;       alias $i="nocorrect $i"
alias grep='grep -I --color=always'
alias egrep='egrep -I --color=always'
alias cal='cal -3m'
alias ls='ls -h --color=auto -X --time-style="+[33m[[32m%Y-%m-%d [35m%k:%M[33m][m"'
alias vi='vim'
alias ll='ls -l'
alias df='df -Th'
alias du='du -h'
#show directories size
alias dud='du -s *(/)'
#date for US and CN
alias adate='for i in US/Eastern Australia/{Brisbane,Sydney} Asia/Hong_Kong; do printf %-22s "$i:";TZ=$i date +"%m-%d %a %H:%M";done'
#bloomberg radio
alias bloomberg='mplayer mms://media2.bloomberg.com/wbbr_sirus.asf'
#alias which='alias | /usr/bin/which --read-alias'
alias pyprof='python -m cProfile'
alias python='nice python'
alias ri='ri -f ansi'
alias history='history 1'       #zsh specific
#alias mplayer='mplayer -cache 512'
alias zhcon='zhcon --utf8'
alias vless="/usr/share/vim/macros/less.sh"
del() {mv -vif -- $* ~/.Trash}
alias m='mutt'
alias port='netstat -ntlp'      #opening ports
alias e264='mencoder -vf harddup -ovc x264 -x264encopts crf=22:subme=5:frameref=2:8x8dct:bframes=3:weight_b:b_pyramid -oac mp3lame -lameopts aq=7:mode=0:vol=1.2:vbr=2:q=6 -srate 32000'
#alias tree="tree --dirsfirst"
alias top10='print -l  ${(o)history%% *} | uniq -c | sort -nr | head -n 10'
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
#alias tt="vim +'set spell' ~/doc/TODO.otl"
alias mlychee="sshfs -p 2023 roy@lychee: /home/roylez/remote/lychee"
alias gfw="ssh -o ServerAliveInterval=60 -CNfg -D 7777 -l roy lychee &>/dev/null &"
#alias rtm="twitter d rtm"
#alias rtorrent="screen rtorrent"
if [ "$HOSTNAME" != 'lychee' ]; then
    for i in showq qstat qdel qnodes showstart; do 
        alias $i="ssh roy@lychee -p 2023 /opt/bin/$i"
    done
    qsub(){ssh roy@lychee -p 2023 "cd ${(S)PWD#lez/remote/lychee};/opt/bin/qsub -o /tmp -e /tmp $1"}
fi
[ -x /usr/bin/pal ] && alias pal="pal -r 0-7 --color"
[ -x /usr/bin/cdf ] && alias df="cdf -h"
if [ -x /usr/bin/grc ]; then
    alias cl="/usr/bin/grc -es --colour=auto"
    for i in diff cat make gcc g++ as gas ld netstat ping traceroute; do
        alias $i="cl $i"
    done
fi

alias tnethack='telnet nethack.alt.org'
alias tslashem='telnet slashem.crash-override.net'

#}}}

# {{{-----------------user defined functions--------------------------------
#show 256 color tab
256tab() {
    for k in `seq 0 1`;do 
        for j in `seq $((16+k*18)) 36 $((196+k*18))`;do 
            for i in `seq $j $((j+17))`; do 
                printf "\e[01;$1;38;5;%sm%4s" $i $i;
            done;echo;
        done;
    done
}

#alarm using atd
alarm() { 
    echo "msg ${argv[2,-1]} && aplay -q ~/.sounds/MACSound/System\ Notifi.wav" | at now + $1 min
}

#{{{ functions to set prompt pwd color
export __PROMPT_PWD="%F{magenta}%~%f"
#change PWD color
pwd_color_chpwd() { export __PROMPT_PWD="%U%F{yellow}%~%f%u" }       
#change back before next command
pwd_color_prexec() { export __PROMPT_PWD="%F{magenta}%~%f" }

get_prompt_pwd() { echo $__PROMPT_PWD }

#}}}

#{{{functions to display git branch in prompt

#get git branch
export __CURRENT_GIT_BRANCH=

parse_git_branch() {
    #do not track git repository sits in $HOME, which is my configurartion dir
    if [ "$PWD" != "$HOME" ]; then
        dir=$(git rev-parse --git-dir 2>/dev/null)
        if [ "${dir:h}" != "$HOME" ]; then
            git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
        fi
    fi
}

git_branch_precmd() {
    case "$(history $HISTCMD)" in 
        *git*)
        export __CURRENT_GIT_BRANCH="$(parse_git_branch)"
        ;;
    esac
}

git_branch_chpwd() { export __CURRENT_GIT_BRANCH="$(parse_git_branch)" }

#this one is to be used in prompt
get_prompt_git() { [ ! -z $__CURRENT_GIT_BRANCH ] && echo "%F{green}$__CURRENT_GIT_BRANCH%f %F{red}|%f " }
#}}}

#{{{-----------------functions to set gnu screen title----------------------
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
screen_precmd() {
    #a bell, urgent notification trigger
    #echo -ne '\a'
    #title "`print -Pn "%~" | sed "s:\([~/][^/]*\)/.*/:\1...:"`" "$TERM $PWD"
    title "`print -Pn "%~" |sed "s:\([~/][^/]*\)/.*/:\1...:;s:\([^-]*-[^-]*\)-.*:\1:"`" "$TERM $PWD"
    echo -ne '\033[?17;0;127c'
}

screen_preexec() {
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

#}}}

#{{{-----------------define magic function arrays--------------------------
typeset -ga preexec_functions precmd_functions chpwd_functions

precmd_functions+=screen_precmd
precmd_functions+=git_branch_precmd

preexec_functions+=screen_preexec
preexec_functions+=pwd_color_prexec

chpwd_functions+=pwd_color_chpwd
chpwd_functions+=git_branch_chpwd

#}}}

# }}}

# {{{---------------------------prompt--------------------------------------
#autoload -U promptinit zmv
#promptinit
if [ "$SSH_TTY" = "" ]; then
    local host="%B%F{magenta}%m%f%b"
else
    local host="%B%F{red}%m%f%b"
fi
local user="%B%(!:%F{red}:%F{green})%n%f%b"       #different color for privileged sessions
local symbol="%B%(!:%F{red}# :%F{yellow}> )%f%b"
local job="%1(j,%F{red}:%F{blue}%j,)%f%b"
PROMPT="$user%F{yellow}@%f$host$job$symbol"
#export RPROMPT="%{$fg_no_bold[${1:-magenta}]%}%~%{$reset_color%}"
#NOTE  **DO NOT** use double quote , it does not work
RPROMPT='$(get_prompt_git)$(get_prompt_pwd)'

# SPROMPT - the spelling prompt
SPROMPT="%F{yellow}zsh%f: correct '%F{red}%B%R%f%b' to '%F{green}%B%r%f%b' ? ([%F{cyan}Y%f]es/[%F{cyan}N%f]o/[%F{cyan}E%f]dit/[%F{cyan}A%f]bort) "

#行编辑高亮模式 {{{
zle_highlight=(region:bg=magenta
               special:bold,fg=magenta
               default:bold
               isearch:underline
               )
#}}}

# }}}

# {{{-----------------key bindings to fix keyboard---------------------------
#bindkey "\M-v" "\`xclip -o\`\M-\C-e\""
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
autoload -U zkbd
bindkey -e      #use emacs style keybindings :(
typeset -A key  #define an array

#if zkbd definition exists, use defined keys instead
if [[ -f ~/.zkbd/${TERM}-${DISPLAY:-$VENDOR-$OSTYPE} ]]; then
    source ~/.zkbd/$TERM-${DISPLAY:-$VENDOR-$OSTYPE}
else
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
    for k in ${(k)key} ; do
        # $terminfo[] entries are weird in ncurses application mode...
        [[ ${key[$k]} == $'\eO'* ]] && key[$k]=${key[$k]/O/[}
    done
fi

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

bindkey "" history-beginning-search-backward
bindkey "" history-beginning-search-forward

# }}}

# {{{-----------------user defined widgets & binds-----------------------
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

#拼音补全
function _pinyin() { reply=($($HOME/bin/chsdir 0 $*)) }

#c-z to continue as well
bindkey -s "" "fg\n"

# }}}

#{{{----------------------distro specific stuff---------------------------
if `cat /etc/issue |grep Arch >/dev/null`; then
    function command_not_found_handler() {
        echo "Man, you really need some coffee. \nA clear-headed one would not type things like \"$1\"."|cowsay -f small -W 50
        if grep Arch /etc/issue >/dev/null; then
            echo 
            pacfile /bin/$1$|awk '{split($1,a,"/");print a[1] "/\033[31m" a[2] "\033[m\t\t\t/" $2}'
        fi
        return 0
    }
fi
#}}}

# {{{----------------------variables---------------------------------------
export PATH=$PATH:$HOME/bin
export EDITOR=vim
export VISUAL=vim
export SUDO_PROMPT='[[31;5msudo[m] password for [33;1m%p[m: '

#MOST like colored man pages
export LESS_TERMCAP_md=$'\E[1;31m'      #bold1
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_me=$'\E[m'
export LESS_TERMCAP_so=$'\E[01;44;33m'  #search highlight
export LESS_TERMCAP_se=$'\E[m'
export LESS_TERMCAP_us=$'\E[1;2;32m'    #bold2
export LESS_TERMCAP_ue=$'\E[m'
export LESS="-M -i -R --shift 5"
export LESSCHARSET=utf-8
export READNULLCMD=less
[ -x /usr/bin/src-hilite-lesspipe.sh ] && export LESSOPEN="| src-hilite-lesspipe.sh %s"

#for ConTeX
#source $HOME/.context_env /home/roylez/soft/ConTeXt/tex

#for gnuplot, avoid locate!!!
#export GDFONTPATH=$(dirname `locate DejaVuSans.ttf | tail -1`)
[[ -n $DISPLAY ]] && export GDFONTPATH=/usr/share/fonts/TTF

#for intel fortran compiler
#source $HOME/soft/intel/ifort/bin/ifortvars.sh

#for slrn
#export NNTPSERVER=news.newsfan.net 

#ruby, damned ruby 1.9 path bug
if [[ $(hostname) == Lancelot ]]; then
    export GEM_HOME=/usr/lib/ruby/1.9.1/rubygems
    export GEM_PATH=$GEM_HOME:$HOME/.gem/ruby/1.9.1
fi

# }}}
