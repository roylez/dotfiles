#!/bin/zsh
# vim:fdm=marker

# 预配置 {{{
# 如果不是交互shell就直接结束 (unix power tool, 2.11)
#if [[  "$-" != *i* ]]; then return 0; fi

export PATH=$HOME/bin:$PATH

[[ -f $HOME/.zshrc.pre ]] && source $HOME/.zshrc.pre

# 定义颜色 {{{
if [[ "$TERM" = *(256color|kitty) && -f $HOME/.lscolor256 ]]; then
  #use prefefined colors
  eval $(dircolors -b $HOME/.lscolor256)
  use_256color=1
else
  [[ -f $HOME/.lscolor ]] && eval $(dircolors -b $HOME/.lscolor)
fi

#color defined for prompts and etc
autoload colors
[[ $terminfo[colors] -ge 8 ]] && colors
pR="%{$reset_color%}%u%b" pB="%B" pU="%U" pS="%S" pSS="%s"
for i in red green blue yellow magenta cyan white black; {eval pfg_$i="%{$fg[$i]%}" pbg_$i="%{$bg[$i]%}"}
#}}}
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
setopt hash_list_all            # search all paths before command completion
setopt no_hist_beep             # don not beep on history expansion errors
setopt hist_reduce_blanks       # reduce whitespace in history
setopt hist_ignore_space        # do not remember commands starting with space
setopt no_share_history         # share history among sessions, conflicts inc_append_history
setopt hist_verify              # reload full command when runing from history
setopt hist_ignore_all_dups     # when runing a command several times, only store one
setopt hist_expire_dups_first   #remove dups when max size reached
setopt inc_append_history       # append to history once executed
setopt hist_fcntl_lock          # use filesystem lock when writing history
setopt hist_no_store            # do not store `history` or `fc -l`
setopt interactive_comments     # comments in history
setopt list_types               # show ls -F style marks in file completion
setopt long_list_jobs           # show pid in bg job list
setopt numeric_glob_sort        # when globbing numbered files, use real counting
setopt prompt_subst             # prompt more dynamic, allow function in prompt
setopt nonomatch
setopt transient_rprompt        # make rprompt dissapear for previous commands

#remove / and . from WORDCHARS to allow alt-backspace to delete word
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

#report to me when people login/logout
watch=(notme)
#replace the default beep with a message
#ZBEEP="\e[?5h\e[?5l"        # visual beep

#is-at-least 4.3.0 &&

# 自动加载自定义函数
fpath=($HOME/.zfunctions $fpath)
# 需要设置了extended_glob才能glob到所有的函数，为了补全能用，又需要放在compinit前面
_my_functions=${fpath[1]}/*(N-.x:t)
[[ -n $_my_functions ]] && autoload -U $_my_functions

autoload -U is-at-least
# }}}

# 命令补全参数{{{
#   zsytle ':completion:*:completer:context or command:argument:tag'
zmodload -i zsh/complist        # for menu-list completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" "ma=${${use_256color+1;7;38;5;143}:-1;7;33}"
#ignore list in completion
zstyle ':completion:*' ignore-parents parent pwd directory
#menu selection in completion
zstyle ':completion:*' menu select=2
zstyle ':completion:*' rehash true          # auto rehash
#zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' completer _oldlist _expand _complete _match #_user_expand
zstyle ':completion:*:match:*' original only
zstyle ':completion:*' user-expand #_pinyin
zstyle ':completion:*:approximate:*' max-errors 1 numeric
## case-insensitive (uppercase from lowercase) completion
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
### case-insensitive (all) completion
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=1;31"
#use cache to speed up pacman completion
zstyle ':completion::complete:*' use-cache on
#zstyle ':completion::complete:*' cache-path .zcache
#group matches and descriptions
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\e[33m == \e[1;7;36m %d \e[m\e[33m ==\e[m'
zstyle ':completion:*:messages' format $'\e[33m == \e[1;7;36m %d \e[m\e[0;33m ==\e[m'
zstyle ':completion:*:warnings' format $'\e[33m == \e[1;7;31m No Matches Found \e[m\e[0;33m ==\e[m'
zstyle ':completion:*:corrections' format $'\e[33m == \e[1;7;37m %d (errors: %e) \e[m\e[0;33m ==\e[m'
# dabbrev for zsh!! M-p M-n
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes select

#autoload -U compinit
autoload -Uz compinit
compinit

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
bin-exist() {[[ -n ${commands[$1]} ]]}

#check if is a local shell
is-local() { [[ -z "$SSH_CONNECTION" || -f ~/.tty.local ]] }

# use stat_cal to generate github style commit log
(bin-exist stat_cal) && \
    git_cal_view() {
        pwd=$PWD
        for i in $*; do
            cd $i
            git log --no-merges --pretty=format:"%ai" --since="13 months"
            echo    # an "\n" is missing at the end of git log command
        done \
            |awk '{ a[$1] ++ }; END {for (i in a) {print i " " a[i]}}' \
            |sort \
            |stat_cal -s $COLUMNS
        cd $pwd
    }


#recalculate track db gain with mp3gain
(bin-exist mp3gain) && id3gain() { find $* -type f -iregex ".*\(mp3\|ogg\|wma\)" -exec mp3gain -r -s i {} \; }

#ccze for log viewing
(bin-exist ccze) && lless() { tac $* |ccze -A |less }

#man page to pdf
(bin-exist ps2pdf) && man2pdf() {  man -t ${1:?Specify man as arg} | ps2pdf -dCompatibility=1.3 - - > ${1}.pdf; }

#help command for builtins
help() { man zshbuiltins | sed -ne "/^       $1 /,/^\$/{s/       //; p}"}

(bin-exist ffmpeg) && extract_mp3() { ffmpeg -i $1 -acodec libmp3lame -metadata TITLE="$2" ${2// /_}.mp3 }

# }}}

#{{{ functions to set prompt pwd color
__PROMPT_PWD="$pfg_magenta%~$pR"
#change PWD color
pwd_color_chpwd() { [ $PWD = $OLDPWD ] || __PROMPT_PWD="$pU$pfg_cyan%~$pR" }
#change back before next command
pwd_color_preexec() { __PROMPT_PWD="$pfg_magenta%~$pR" }

#}}}

#{{{functions to display git branch in prompt

get_git_status() {
    unset -m '__CURRENT_GIT_BRANCH*'

    # do not track git branch info in ~
    [[ "$PWD" = "$HOME" ]]  &&  return
    local dir=$(git rev-parse --git-dir 2>/dev/null)
    [[ "${dir:h}" = "$HOME" ]] && return

    local st="$(git -c color.status=false status 2>/dev/null)"
    if [[ -n "$st" ]]; then
        local -a arr
        arr=(${(f)st})

        if [[ $arr[1] =~ 'Not currently on any branch.' ]]; then
            __CURRENT_GIT_BRANCH='no-branch'
        else
            __CURRENT_GIT_BRANCH="${arr[1][(w)4]}"
            [[ $__CURRENT_GIT_BRANCH == "master" ]] && __CURRENT_GIT_BRANCH=M
        fi

        if [[ $arr[2] =~ 'Your branch is' ]]; then
            case $arr[2] in
                *ahead*    ) __CURRENT_GIT_BRANCH_STATUS=ahead      ;;
                *diverged* ) ""__CURRENT_GIT_BRANCH_STATUS=diverged   ;;
                *date*     ) __CURRENT_GIT_BRANCH_STATUS=up-to-date ;;
                *          ) __CURRENT_GIT_BRANCH_STATUS=behind     ;;
            esac
        fi

        # has something new?
        [[ ! $st =~ "nothing to commit" ]] && __CURRENT_GIT_BRANCH_IS_DIRTY='1'
        # has unstaged changes?
        [[ $st =~ "not staged for commit" ]] && __CURRENT_GIT_BRANCH_HAS_UNSTAGED='1'
    fi
}

git_branch_precmd() { [[ "$(fc -l -1)" == *git* ]] && get_git_status }

git_branch_chpwd() { get_git_status }

#this one is to be used in prompt
get_prompt_git() {
    if [[ -n $__CURRENT_GIT_BRANCH ]]; then
        local s=$__CURRENT_GIT_BRANCH
        case "$__CURRENT_GIT_BRANCH_STATUS" in
            ahead) s+="${pbg_green}+" ;;
            diverged) s+="${pbg_red}=" ;;
            behind) s+="${pbg_magenta}-" ;;
        esac
        if [[ $__CURRENT_GIT_BRANCH_IS_DIRTY = '1' ]]; then
            if [[ $__CURRENT_GIT_BRANCH_HAS_UNSTAGED = '1' ]]; then
                s+="${pbg_red}*"
            else
                s+="${pbg_green}*"
            fi
        fi
        echo " $pfg_black$pbg_white$pS$pB $s $pR$pSS"
    fi
}
#}}}

#{{{ functions to set gnu screen title
# active command as title in terminals
function title() {}
if is-local; then
  case $TERM in
    xterm*|rxvt*) function title() { print -nP "\e]0;$1\a" } ;;
    tmux*)        function title() { print -nP "\e]2;$1\a" } ;;
    screen*)      function title() { print -nP "\ek$1\e\\" } ;;
  esac
fi

#set screen title if not connected remotely
#if [ "$STY" != "" ]; then
screen_precmd() {
    #a bell, urgent notification trigger
    #echo -ne '\a'
    #title "`print -Pn "%~" | sed "s:\([~/][^/]*\)/.*/:\1...:"`" "$TERM $PWD"
    title "`print -Pn "%~" |sed "s:\([~/][^/]*\)/.*/:\1..:;s:\([^-]*-[^-]*\)-.*:\1:"`" "$TERM $PWD"
    echo -ne '\033[?17;0;127c'
}

screen_preexec() {
    local -a cmd; cmd=(${(z)1})
    case $cmd[1]:t in
        'ssh'|'mosh') title "@""`echo $cmd[-1]|sed 's:.*@::;s:\..*$::'`" "$TERM $cmd";;
        'sudo')       title "#"$cmd[2]:t "$TERM $cmd[3,-1]";;
        'for')        title "()"$cmd[7] "$TERM $cmd";;
        'svn'|'git')  title "$cmd[1,2]" "$TERM $cmd";;
        'ls'|'ll')    ;;
        *)            title $cmd[1]:t "$TERM $cmd[2,-1]";;
    esac
}

#}}}

#{{{define magic function arrays
# typeset -ga preexec_functions precmd_functions chpwd_functions
autoload -Uz add-zsh-hook
add-zsh-hook precmd  screen_precmd
add-zsh-hook precmd  git_branch_precmd
add-zsh-hook preexec screen_preexec
add-zsh-hook preexec pwd_color_preexec
add-zsh-hook chpwd   pwd_color_chpwd
add-zsh-hook chpwd   git_branch_chpwd
#}}}

# }}}

# 提示符 {{{
if [ "$SSH_TTY" = "" ]; then
    local host="$pB$pfg_magenta%m$pR"
else
    local host="$pB$pU$pfg_magenta%m$pR"            # underline for remote hostname
fi
local user="$pB%(!:$pfg_red:$pfg_green)%n$pR"       # red for root user name
local symbol="$pB%(!:$pfg_red# :$pfg_yellow > )$pR"
# local symbol="$pB$pfg_yellow> $pR"
local job="%1(j,$pfg_red:$pfg_blue%j,)$pR"
PROMPT='$host $user $__PROMPT_PWD$(get_prompt_git)$job$symbol'
PROMPT2="$PROMPT$pfg_cyan%_$pR $pB$pfg_black>$pR$pfg_green>$pB$pfg_green>$pR "
# RPROMPT='$__PROMPT_PWD'

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
# history search can be implemented with the following widgets
#   history-search-end
#   up-line-or-beginning-search / down-line-or-beginning-search
# but history-search-end provides better compatibility with older zsh versions
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "" history-beginning-search-backward-end
bindkey "" history-beginning-search-forward-end
bindkey -M viins "" history-beginning-search-backward-end
bindkey -M viins "" history-beginning-search-forward-end
bindkey '[1;5D' backward-word     # C-left
bindkey '[1;5C' forward-word      # C-right

autoload -U edit-command-line
zle -N      edit-command-line
bindkey '\ee' edit-command-line

# dabbrev for zsh!! M-p M-n
bindkey '\ep' _history-complete-older
bindkey '\en' _history-complete-newer
# }}}

# }}}

# ZLE 自定义widget {{{
#

# {{{ pressing TAB in an empty command makes a cd command with completion list
# from linuxtoy.org
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
# }}}

# {{{ colorize commands
TOKENS_FOLLOWED_BY_COMMANDS=('|' '||' ';' '&' '&&' 'sudo' 'do' 'time' 'strace')

recolor-cmd() {
    region_highlight=()
    colorize=true
    start_pos=0
    for arg in ${(z)BUFFER}; do
        ((start_pos+=${#BUFFER[$start_pos+1,-1]}-${#${BUFFER[$start_pos+1,-1]## #}}))
        ((end_pos=$start_pos+${#arg}))
        if $colorize; then
            colorize=false
            res=$(LC_ALL=C builtin type $arg 2>/dev/null)
            case $res in
                *'reserved word'*)   style="fg=magenta,bold";;
                *'alias for'*)       style="fg=cyan,bold";;
                *'shell builtin'*)   style="fg=yellow,bold";;
                *'shell function'*)  style='fg=green,bold';;
                *"$arg is"*)
                    [[ $arg = 'sudo' ]] && style="fg=red,bold" || style="fg=blue,bold";;
                *)                   style='none,bold';;
            esac
            region_highlight+=("$start_pos $end_pos $style")
        fi
        [[ ${${TOKENS_FOLLOWED_BY_COMMANDS[(r)${arg//|/\|}]}:+yes} = 'yes' ]] && colorize=true
        start_pos=$end_pos
    done
}

check-cmd-self-insert() { zle .self-insert && recolor-cmd }
check-cmd-backward-delete-char() { zle .backward-delete-char && recolor-cmd }

zle -N self-insert check-cmd-self-insert
zle -N backward-delete-char check-cmd-backward-delete-char
# }}}

# {{{ double ESC to prepend "sudo"
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line                 #光标移动到行末
}
zle -N sudo-command-line
#定义快捷键为： [Esc] [Esc]
bindkey "\e\e" sudo-command-line
# }}}

# {{{ c-z to continue
fancy-ctrl-z () {
if [[ $#BUFFER -eq 0 ]]; then
  BUFFER="fg"
  zle accept-line
else
  zle push-input
  zle clear-screen
fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z
# }}}

# {{{ esc-enter to run program in screen split region
function run-command-in-split-screen() {
    screen -X eval \
        "focus bottom" \
        split \
        "focus bottom" \
        "screen $HOME/bin/screen_run $BUFFER" \
        "focus top"
    zle kill-buffer
}
zle -N run-command-in-split-screen
bindkey "\e\r" run-command-in-split-screen
# }}}

# }}}

# 环境变量及其他参数 {{{
# location of history
export HISTFILE=$HOME/.zsh_history
# number of lines kept in history
export HISTSIZE=20000
# number of lines saved in the history before logout
export SAVEHIST=40000
export EDITOR=vim
export VISUAL=vim
export SUDO_PROMPT=$'[\e[31;5msudo\e[m] password for \e[33;1m%p\e[m: '
export INPUTRC=$HOME/.inputrc

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#MOST like colored man pages
export PAGER=less
export LESS_TERMCAP_md=$'\E[1;31m'      #bold1
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_me=$'\E[m'
export LESS_TERMCAP_so=$'\E[01;7;34m'  #search highlight
export LESS_TERMCAP_se=$'\E[m'
export LESS_TERMCAP_us=$'\E[1;2;32m'    #bold2
export LESS_TERMCAP_ue=$'\E[m'
export LESS="-M -i -R --shift 5"
export LESSCHARSET=utf-8
export READNULLCMD=less
# In archlinux the pipe script is in PATH, how ever in debian it is not
(bin-exist src-hilite-lesspipe.sh) && export LESSOPEN="| src-hilite-lesspipe.sh %s"
[ -x /usr/share/source-highlight/src-hilite-lesspipe.sh ] && export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"

#for gnuplot, avoid locate!!!
#export GDFONTPATH=$(dirname `locate DejaVuSans.ttf | tail -1`)
#[[ -n $DISPLAY ]] && export GDFONTPATH=/usr/share/fonts/TTF

# redefine command not found
(bin-exist cowsay) && (bin-exist fortune) && command_not_found_handler() { fortune -s| cowsay -W 70; return 127;}

# }}}

# 读入其他配置 {{{

if [[ -d $HOME/.zplug ]]; then
  # git clone https://github.com/zplug/zplug ~/.zplug
  source $HOME/.zplug/init.zsh
  [[ -f $HOME/.zshrc.plug ]] && source $HOME/.zshrc.plug
fi
[[ -f $HOME/.zshrc.$(hostname -s) ]] && source $HOME/.zshrc.$(hostname -s)
[[ -f $HOME/.zshrc.local ]]          && source $HOME/.zshrc.local

if (bin-exist kubectl); then
  source <(kubectl completion zsh)
  alias k=kubectl
  compdef k=kubectl
fi
if ( bin-exist docker-compose ); then
  alias dc=docker-compose
  ( command -v _docker-compose &>/dev/null ) && compdef dc=docker-compose
fi

if ( bin-exist docker ); then
  alias d=docker
  ( command -v _docker &>/dev/null ) && compdef d=docker
fi

# }}}

# 命令别名 {{{
# alias and listing colors
alias -g A="|awk"
alias -g B='|sed -r "s:\x1B\[[0-9;]*[mK]::g"'       # remove color, make things boring
alias -g C="|cut -d' '"
alias -g E="|sed"
alias -g G='|GREP_COLOR=$(echo 3$[$(date +%s%N)/1000%6+1]'\'';1;7'\'') egrep -i --color=always'
alias -g H="|head -n $(($LINES-2))"
alias -g L="|less -R"
alias -g P="|column -t"
alias -g R="|tac"
alias -g S="|sort"
alias -g T="|tail -n $(($LINES-2))"
alias -g W="|wc"
alias -g X="|xargs"
alias -g N="> /dev/null"
alias -g NF="./*(oc[1])"      # last modified(inode time) file or directory

#file types
alias -s ps=gv
for i in avi rmvb wmv;      alias -s $i=mplayer
for i in rar zip 7z lzma;   alias -s $i="7z x"

#no correct for mkdir mv and cp
for i in mkdir mv cp;       alias $i="nocorrect $i"
alias find='noglob find'        # noglob for find
alias rsync='noglob rsync'
alias grep='grep -I --color=auto'
alias egrep='egrep -I --color=auto'
alias freeze='kill -STOP'
alias ls=$'ls -h --quoting-style=escape --color=auto -X --group-directories-first --time-style="+\e[33m[\e[32m%Y-%m-%d \e[35m%k:%M\e[33m]\e[m"'
alias vi='vim'
# alias ll='ls -li -ctr'
alias ll='ls -li'
alias df='df -Th'
alias du='du -h'
alias dmesg='dmesg -H'
#show directories size
alias dud='du -s *(/)'
#date for US and CN
alias adate='for i in GMT US/Eastern Australia/{Brisbane,Sydney,Adelaide} Asia/{Hong_Kong,Singapore} UK/London Europe/Paris; do printf %-22s "$i:";TZ=$i date +"%m-%d %a %H:%M";done'
#bloomberg radio
alias info='info --vi-keys'
alias rsync='rsync --progress --partial'
alias history='history 1'       #zsh specific
alias vless="/usr/share/vim/vim72/macros/less.sh"
alias m='mutt'
#Terminal - Harder, Faster, Stronger SSH clients
alias e264='mencoder -vf harddup -ovc x264 -x264encopts crf=22:subme=6:frameref=2:8x8dct:bframes=3:weight_b:threads=auto -oac copy'
alias top10='print -l  ${(o)history%% *} | uniq -c | sort -nr | head -n 10'
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias gfw="ssh -C2g -o ServerAliveInterval=60 -D 7070"
[ -d /usr/share/man/zh_CN ] && alias cman="MANPATH=/usr/share/man/zh_CN man"
alias tnethack='telnet nethack.alt.org'
alias tslashem='telnet slashem.crash-override.net'
alias forget='unset HISTFILE'

#}}}

typeset -U PATH
