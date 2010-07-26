#!/bin/zsh
# vim:fdm=marker

# 预配置 {{{
# 如果不是交互shell就直接结束 (unix power tool, 2.11)
if [[  "$-" != *i* ]]; then return 0; fi

# 主机特定的配置，前置的主要原因是有可能需要提前设置PATH等环境变量
#   例如在aix主机，需要把 /usr/linux/bin
#   置于PATH最前以便下面的配置所调用的命令是linux的版本
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# 为兼容旧版本定义 is-at-least 函数
function is-at-least {
    local IFS=".-" min_cnt=0 ver_cnt=0 part min_ver version

    min_ver=(${=1})
    version=(${=2:-$ZSH_VERSION} 0)

    while (( $min_cnt <= ${#min_ver} )); do
      while [[ "$part" != <-> ]]; do
        (( ++ver_cnt > ${#version} )) && return 0
        part=${version[ver_cnt]##*[^0-9]}
      done

      while true; do
        (( ++min_cnt > ${#min_ver} )) && return 0
        [[ ${min_ver[min_cnt]} = <-> ]] && break
      done

      (( part > min_ver[min_cnt] )) && return 0
      (( part < min_ver[min_cnt] )) && return 1
      part=''
    done
}

export SHELL=`which zsh`
#}}}

# 定义颜色 {{{
if [[ ("$TERM" == *256color || "$TERM" == screen*) && -f $HOME/.lscolor256 ]]; then
    #use prefefined colors
    eval $(dircolors -b $HOME/.lscolor256)
else
    [[ -f $HOME/.lscolor ]] && eval $(dircolors -b $HOME/.lscolor)
fi

#color defined for prompts and etc
autoload -U colors
[[ $terminfo[colors] -ge 8 ]] && colors
pR="%{$reset_color%}%u%b" pB="%B" pU="%U"
for i in red green blue yellow magenta cyan white black; {eval pfg_$i="%{$fg[$i]%}" pbg_$i="%{$bg[$i]%}"}
#}}}

# 设置参数 {{{
setopt complete_aliases         #do not expand aliases _before_ completion has finished
setopt auto_cd                  # if not a command, try to cd to it.
setopt auto_pushd               # automatically pushd directories on dirstack
setopt auto_continue            #automatically send SIGCON to disowned jobs
setopt extended_glob            # so that patterns like ^() *~() ()# can be used
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
setopt hist_ignore_space        # do not remember commands starting with space
setopt share_history            # share history among sessions
setopt hist_verify              # reload full command when runing from history
setopt hist_expire_dups_first   #remove dups when max size reached
setopt interactive_comments     # comments in history
setopt list_types               # show ls -F style marks in file completion
setopt long_list_jobs           # show pid in bg job list
setopt numeric_glob_sort        # when globbing numbered files, use real counting
setopt inc_append_history       # append to history once executed
setopt prompt_subst             # prompt more dynamic, allow function in prompt

#remove / and . from WORDCHARS to allow alt-backspace to delete word
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

#report to me when people login/logout
watch=(notme)
#replace the default beep with a message
#ZBEEP="\e[?5h\e[?5l"        # visual beep

#is-at-least 4.3.0 && 
# }}}

# 命令补全参数{{{
#   zsytle ':completion:*:completer:context or command:argument:tag'
zmodload -i zsh/complist        # for menu-list completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*' list-colors '=%*=01;31' 
#ignore list in completion
zstyle ':completion:*' ignore-parents parent pwd directory
#menu selection in completion
zstyle ':completion:*' menu select=1
#zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _match #_user_expand
zstyle ':completion:*:match:*' original only 
#zstyle ':completion:*' user-expand _pinyin
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

#force rehash when command not found
#  http://zshwiki.org/home/examples/compsys/general
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1    # Because we did not really complete anything
}

# }}}

# 自定义函数 {{{
# 普通自定义函数 {{{
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

#calculator
calc()  { awk "BEGIN{ print $* }" ; }

#check if a binary exists in path
bin-exist() {[[ -x `whence -cp $1 2>/dev/null` ]]}

#recalculate track db gain with mp3gain
(bin-exist mp3gain) && id3gain() { find $* -type f -iregex ".*\(mp3\|ogg\|wma\)" -exec mp3gain -r -s i {} \; }

#ccze for log viewing
(bin-exist ccze) && lless() { tac $* |ccze -A |less }

#man page to pdf
(bin-exist ps2pdf) && man2pdf() {  man -t ${1:?Specify man as arg} | ps2pdf -dCompatibility=1.3 - - > ${1}.pdf; }

# }}}

#{{{ functions to set prompt pwd color
__PROMPT_PWD="$pfg_magenta%~$pR"
#change PWD color
pwd_color_chpwd() { __PROMPT_PWD="$pU$pfg_cyan%~$pR" }
#change back before next command
pwd_color_prexec() { __PROMPT_PWD="$pfg_magenta%~$pR" }

get_prompt_pwd() { echo $__PROMPT_PWD }

#}}}

#{{{functions to display git branch in prompt

get_git_status() {
    unset __CURRENT_GIT_BRANCH
    unset __CURRENT_GIT_BRANCH_STATUS
    unset __CURRENT_GIT_BRANCH_IS_DIRTY

    # do not track git branch info in ~
    [[ "$PWD" = "$HOME" ]]  &&  return
    local dir=$(git rev-parse --git-dir 2>/dev/null)
    [[ "${dir:h}" = "$HOME" ]] && return

    local st="$(git status 2>/dev/null)"
    if [[ -n "$st" ]]; then
        local -a arr
        arr=(${(f)st})

        if [[ $arr[1] = 'Not currently on any branch.' ]]; then
            __CURRENT_GIT_BRANCH='no-branch'
        else
            __CURRENT_GIT_BRANCH="${arr[1][(w)4]}";
        fi

        if [[ $arr[2] = 'Your branch is' ]]; then
            if [[ $arr[2] = 'ahead' ]]; then
                __CURRENT_GIT_BRANCH_STATUS='ahead'
            elif [[ $arr[2] = 'diverged' ]]; then
                __CURRENT_GIT_BRANCH_STATUS='diverged'
            else
                __CURRENT_GIT_BRANCH_STATUS='behind'
            fi
        fi

        [[ ! $st = 'nothing to commit' ]] && __CURRENT_GIT_BRANCH_IS_DIRTY='1'
    fi
}

git_branch_precmd() { [[ "$(fc -l -1)" == *git* ]] && get_git_status }

git_branch_chpwd() { get_git_status }

#this one is to be used in prompt
get_prompt_git() { 
    if [[ -n $__CURRENT_GIT_BRANCH ]]; then
        local s=$__CURRENT_GIT_BRANCH
        case "$__CURRENT_GIT_BRANCH_STATUS" in
            ahead) s+="+" ;;
            diverged) s+="=" ;;
            behind) s+="-" ;;
        esac
        [[ -n "$__CURRENT_GIT_BRANCH_IS_DIRTY" ]] && s+="*"
        echo " $pfg_black$pbg_white$pB $s $pR" 
    fi
}
#}}}

#{{{-----------------functions to set gnu screen title----------------------
# active command as title in terminals
case $TERM in
    xterm*|rxvt*)
        function title() { print -nP "\e]0;$1\a" } 
        ;;
    screen*)
        #only set screen title if it is in a local shell
        if [ -n $STY ] && (screen -ls |grep $STY &>/dev/null); then
            function title() 
            {
                #modify screen title
                print -nP "\ek$1\e\\"
                #modify window title bar
                #print -nPR $'\033]0;'$2$'\a'
            } 
        elif [ -n $TMUX ]; then       # actually in tmux !
            function title() {  print -nP "\e]2;$1\a" }
        else
            function title() {}
        fi
        ;;
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
if ! (is-at-least 4.3); then
    #the following solution should work on older version <4.3 of zsh. 
    #The "function" keyword is essential for it to work with the old zsh.
    #NOTE these function fails dynamic screen title, not sure why
    #CentOS stinks.
    function precmd() {
        screen_precmd 
        git_branch_precmd
    }

    function preexec() {
        screen_preexec
        pwd_color_prexec
    }

    function chpwd() {
        pwd_color_chpwd
        git_branch_chpwd
    }
else
    #this works with zsh 4.3.*, will remove the above ones when possible
    typeset -ga preexec_functions precmd_functions chpwd_functions
    precmd_functions+=screen_precmd
    precmd_functions+=git_branch_precmd
    preexec_functions+=screen_preexec
    preexec_functions+=pwd_color_prexec
    chpwd_functions+=pwd_color_chpwd
    chpwd_functions+=git_branch_chpwd
fi

#}}}

# }}}

# 命令别名 {{{
# alias and listing colors
alias -g A="|awk"
alias -g B='|sed -r "s:\x1B\[[0-9;]*[mK]::g"'       # remove color, make things boring
alias -g C="|wc"
alias -g E="|sed"
alias -g G="|egrep"
alias -g H="|head -n $(($LINES-2))"
alias -g L="|less"
alias -g P="|column -t"
alias -g R="|tac"
alias -g S="|sort"
alias -g T="|tail -n $(($LINES-2))"
alias -g X="|xargs"
alias -g N="> /dev/null"
alias -g NF="./*(oc[1])"      # last modified(inode time) file or directory

#file types
(bin-exist apvlv) && alias -s pdf=apvlv
alias -s ps=gv
for i in jpg png;           alias -s $i=gqview
for i in avi rmvb wmv;      alias -s $i=mplayer
for i in rar zip 7z lzma;   alias -s $i="7z x"

#no correct for mkdir mv and cp
for i in mkdir mv cp;       alias $i="nocorrect $i"
alias grep='grep -I --color=always'
alias egrep='egrep -I --color=always'
alias cal='cal -3m'
alias freeze='kill -STOP'
alias ls='ls -h --color=auto -X --time-style="+[33m[[32m%Y-%m-%d [35m%k:%M[33m][m"'
alias vi='vim'
alias ll='ls -l'
alias df='df -Th'
alias du='du -h'
#show directories size
alias dud='du -s *(/)'
#date for US and CN
alias adate='for i in US/Eastern Australia/{Brisbane,Sydney} Asia/{Hong_Kong,Singapore} Europe/Paris; do printf %-22s "$i:";TZ=$i date +"%m-%d %a %H:%M";done'
#bloomberg radio
alias bloomberg='mplayer mms://media2.bloomberg.com/wbbr_sirus.asf'
alias pyprof='python -m cProfile'
alias python='nice python'
alias info='info --vi-keys'
alias ri='ri -f ansi'
alias history='history 1'       #zsh specific
alias zhcon='zhcon --utf8'
alias vless="/usr/share/vim/vim72/macros/less.sh"
del() {mv -vif -- $* ~/.Trash}
alias m='mutt'
alias port='netstat -ntlp'      #opening ports
#Terminal - Harder, Faster, Stronger SSH clients 
#alias ssh="ssh -4 -C -c blowfish-cbc"
alias e264='mencoder -vf harddup -ovc x264 -x264encopts crf=22:subme=5:frameref=2:8x8dct:bframes=3:weight_b -oac mp3lame -lameopts aq=7:mode=0:vol=1.2:vbr=2:q=6 -srate 32000'
#alias tree="tree --dirsfirst"
alias top10='print -l  ${(o)history%% *} | uniq -c | sort -nr | head -n 10'
#alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
#alias gfw="ssh -o ServerAliveInterval=60 -CNfg -D 7777 -l roy lychee &>/dev/null &"
alias gfw="ssh -o ServerAliveInterval=60 -Cg -D 7070"
(bin-exist pal) && alias pal="pal -r 0-7 --color"
[ -d /usr/share/man/zh_CN ] && alias cman="MANPATH=/usr/share/man/zh_CN man"
alias tnethack='telnet nethack.alt.org'
alias tslashem='telnet slashem.crash-override.net'

#}}}

# 提示符 {{{
if [ "$SSH_TTY" = "" ]; then
    local host="$pB$pfg_magenta%m$pR"
else
    local host="$pB$pfg_red%m$pR"
fi
local user="$pB%(!:$pfg_red:$pfg_green)%n$pR"       #different color for privileged sessions
local symbol="$pB%(!:$pfg_red# :$pfg_yellow> )$pR"
local job="%1(j,$pfg_red:$pfg_blue%j,)$pR"
PROMPT='$user$pfg_yellow@$pR$host$(get_prompt_git)$job$symbol'
PROMPT2="$PROMPT$pfg_cyan%_$pR $pB$pfg_black>$pR$pfg_green>$pB$pfg_green>$pR "
#NOTE  **DO NOT** use double quote , it does not work
typeset -A altchar
set -A altchar ${(s..)terminfo[acsc]}
PR_SET_CHARSET="%{$terminfo[enacs]%}"
PR_SHIFT_IN="%{$terminfo[smacs]%}"
PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
#PR_RSEP=$PR_SET_CHARSET$PR_SHIFT_IN${altchar[\`]:-|}$PR_SHIFT_OUT
RPROMPT='$(get_prompt_pwd)'

# SPROMPT - the spelling prompt
SPROMPT="${pfg_yellow}zsh$pR: correct '$pfg_red$pB%R$pR' to '$pfg_green$pB%r$pR' ? ([${pfg_cyan}Y$pR]es/[${pfg_cyan}N$pR]o/[${pfg_cyan}E$pR]dit/[${pfg_cyan}A$pR]bort) "

#行编辑高亮模式 {{{
if (is-at-least 4.3); then
    zle_highlight=(region:bg=magenta
                   special:bold,fg=magenta
                   default:bold
                   isearch:underline
                   )
fi
#}}}

# }}}

# 键盘定义及键绑定 {{{
#bindkey "\M-v" "\`xclip -o\`\M-\C-e\""
# 设置键盘 {{{
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

# }}}

# 键绑定  {{{ 
bindkey "" history-beginning-search-backward
bindkey "" history-beginning-search-forward
bindkey '[1;5D' backward-word     # C-left
bindkey '[1;5C' forward-word      # C-right

autoload -U edit-command-line
zle -N      edit-command-line
bindkey '\ee' edit-command-line
# }}}

# }}}

# 自定义widget {{{
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

# 特定发行版配置 {{{
#if `cat /etc/issue |grep Arch >/dev/null`; then
    #function command_not_found_handler() {
        #echo "Man, you really need some coffee. \nA clear-headed one would not type things like \"$1\"."|cowsay -f small -W 50
        #if grep Arch /etc/issue >/dev/null; then
            #echo 
            #pacfile /bin/$1$|awk '{split($1,a,"/");print a[1] "/\033[31m" a[2] "\033[m\t\t\t/" $2}'
        #fi
        #return 0
    #}
#fi
#}}}

# 环境变量及其他参数 {{{
# number of lines kept in history
export HISTSIZE=10000
# number of lines saved in the history after logout
export SAVEHIST=10000
# location of history
export HISTFILE=$HOME/.zsh_history

export PATH=$PATH:$HOME/bin
export EDITOR=vim
export VISUAL=vim
export SUDO_PROMPT='[[31;5msudo[m] password for [33;1m%p[m: '

#MOST like colored man pages
export PAGER=less
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
# In archlinux the pipe script is in PATH, how ever in debian it is not
(bin-exist src-hilite-lesspipe.sh) && export LESSOPEN="| src-hilite-lesspipe.sh %s"
[ -x /usr/share/source-highlight/src-hilite-lesspipe.sh ] && export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"

#for ConTeX
#source $HOME/.context_env /home/roylez/soft/ConTeXt/tex

#for gnuplot, avoid locate!!!
#export GDFONTPATH=$(dirname `locate DejaVuSans.ttf | tail -1`)
[[ -n $DISPLAY ]] && export GDFONTPATH=/usr/share/fonts/TTF

#for intel fortran compiler
#source $HOME/soft/intel/ifort/bin/ifortvars.sh

#clear up PATH
typeset -U PATH
# }}}
