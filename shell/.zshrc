#!/bin/zsh
# vim:fdm=marker

# 预配置 {{{
export PATH=$HOME/bin:/usr/local/bin:$PATH

[[ -f $HOME/.zshrc.pre ]] && source $HOME/.zshrc.pre

# 如果不是交互shell就直接结束 (unix power tool, 2.11)
if [[  "$-" != *i* ]]; then return 0; fi

# disable flow controll so that ctl-s does not freeze terminal and you don't
# have to ctrl-q to reenable it
stty -ixon
# }}}

# 定义颜色 {{{
if [[ "$TERM" = *(256color|kitty|tmux) && -f $HOME/.lscolor256 ]]; then
  #use prefefined colors
  eval $(dircolors -b $HOME/.lscolor256)
  use_256color=1
else
  [[ -f $HOME/.lscolor ]] && eval $(dircolors -b $HOME/.lscolor)
fi

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
setopt hist_verify              # reload full command when runing from history
setopt hist_ignore_all_dups     # when runing a command several times, only store one
setopt hist_expire_dups_first   #remove dups when max size reached
setopt no_inc_append_history_time no_inc_append_history share_history  # append to history once executed
setopt hist_fcntl_lock          # use filesystem lock when writing history
setopt hist_no_store            # do not store `history` or `fc -l`

setopt interactive_comments     # comments in history
setopt list_types               # show ls -F style marks in file completion
setopt long_list_jobs           # show pid in bg job list
setopt numeric_glob_sort        # when globbing numbered files, use real counting
setopt prompt_subst             # prompt more dynamic, allow function in prompt
setopt csh_null_glob
setopt transient_rprompt        # make rprompt dissapear for previous commands
setopt monitor                  # needed for job control

#remove / and . from WORDCHARS to allow alt-backspace to delete word
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

#report to me when people login/logout
watch=(notme)
#replace the default beep with a message
#ZBEEP="\e[?5h\e[?5l"        # visual beep

# 自动加载自定义函数
fpath=($HOME/.zfunctions $fpath)
# 需要设置了extended_glob才能glob到所有的函数，为了补全能用，又需要放在compinit前面
_my_functions=${fpath[1]}/*(N-.x:t)
[[ -n $_my_functions ]] && autoload -U $_my_functions
# }}}

# 设置键盘 {{{
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
[[ $OSTYPE = darwin* ]] && DISTRO=$OSTYPE.$(uname -m) || DISTRO=$(awk -F\" '/^NAME/ {print $2}' /etc/os-release).$(uname -m)

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

# https://gist.github.com/ctechols/ca1035271ad134841284
# On slow systems, checking the cached .zcompdump file to see if it must be 
# regenerated adds a noticable delay to zsh startup.  This little hack restricts 
# it to once a day.  It should be pasted into your own completion file.
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
autoload -Uz compinit
[[ -n $HOME/.zcompdump(#qN.mh+24) ]] && compinit || compinit -C
# }}}

# 环境变量命令别名等 {{{
# location of history
HISTFILE=$HOME/.zsh_history
# number of lines kept in history
HISTSIZE=20000
# number of lines saved in the history before logout
SAVEHIST=40000
# ignore some commands
HISTORY_IGNORE="(l[ls] *|less *|z *|cd *|pwd|rm *|exit|[bf]g|jobs)"

export SUDO_PROMPT=$'[\e[31;5msudo\e[m] password for \e[33m%p\e[m: '
export INPUTRC=$HOME/.inputrc

export LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

#MOST like colored man pages
export PAGER=less LESS="-M -i -R --shift 5" LESSCHARSET=utf-8 READNULLCMD=less
export LESS_TERMCAP_md=$'\e[1;34m'      #bold
export LESS_TERMCAP_mb=$'\e[1;33m'      #blinking
export LESS_TERMCAP_me=$'\e[m'          #end all modes
export LESS_TERMCAP_so=$'\e[01;7;34m'   #search highlight, standout mode
export LESS_TERMCAP_se=$'\e[m'          #end standout mode
export LESS_TERMCAP_us=$'\e[1;32m'      #underlining
export LESS_TERMCAP_ue=$'\e[m'          #end underlining

# alias and listing colors
alias -g A="|awk"
alias -g B='|sed -r "s:\x1B\[[0-9;]*[mK]::g"'       # remove color, make things boring
alias -g C="|cut -d' '"
alias -g E="|sed"
alias -g G='|GREP_COLORS=$(echo 3$[$(date +%s%N)/1000%6+1]'\'';1;7'\'') grep -E -a -i --color=always'
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

#no correct for mkdir mv and cp
for i in mkdir mv cp;       alias $i="nocorrect $i"
alias find='noglob find'        # noglob for find
alias rsync='noglob rsync'
alias grep='grep -a -I --color=auto'
alias freeze='kill -STOP'
alias ls=$'ls -h --hyperlink=auto --quoting-style=escape --color=auto -X --group-directories-first --time-style="+\e[33m[\e[32m%Y-%m-%d \e[35m%k:%M\e[33m]\e[m"'
alias vi='vim'
alias ll='ls -lctr'
# alias ll='ls -li'
alias df='df -Th'
alias du='du -h'
alias dmesg='dmesg -H'
#show directories size
alias dud='du -s *(/)'
#bloomberg radio
alias info='info --vi-keys'
alias rsync='rsync --progress --partial'
alias history='history 1'       #zsh specific
alias m='mutt'
#Terminal - Harder, Faster, Stronger SSH clients
alias e264='mencoder -vf harddup -ovc x264 -x264encopts crf=22:subme=6:frameref=2:8x8dct:bframes=3:weight_b:threads=auto -oac copy'
alias top10='print -l  ${(o)history%% *} | uniq -c | sort -nr | head -n 10'
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias gfw="ssh -C2g -o ServerAliveInterval=60 -D 7070"
[ -d /usr/share/man/zh_CN ] && alias cman="MANPATH=/usr/share/man/zh_CN man"
alias forget='unset HISTFILE'

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
    done; echo
    for i in {234..255}; do printf "\e[01;$1;38;5;%sm%4s" $i  $i; done; echo
}

#calculator
calc()  { awk "BEGIN{ print $* }" ; }

#check if a binary exists in path
_has() {[[ -n ${commands[$1]} ]]}

#check if is a local shell
is-local() { [[ -z "$SSH_CONNECTION" && -z "$ET_VERSION" || -f ~/.tty.local ]] }

#git directory/repo name
git_repo() { basename $(git rev-parse --show-toplevel) }

#recalculate track db gain with mp3gain
(_has mp3gain) && id3gain() { find $* -type f -iregex ".*\(mp3\|ogg\|wma\)" -exec mp3gain -r -s i {} \; }

#man page to pdf
(_has ps2pdf) && man2pdf() {  man -t ${1:?Specify man as arg} | ps2pdf -dCompatibility=1.3 - - > ${1}.pdf; }

#help command for builtins
help() { man zshbuiltins | sed -ne "/^       $1 /,/^\$/{s/       //; p}"}

(_has ffmpeg) && extract_mp3() { ffmpeg -i $1 -acodec libmp3lame -metadata TITLE="$2" ${2// /_}.mp3 }

# }}}

#{{{ functions to set prompt pwd color
__PROMPT_PWD="%F{magenta}%~%f"
#change PWD color
_pwd_color_chpwd() { [ $PWD = $OLDPWD ] || __PROMPT_PWD="%B%F{yellow}%~%f%u" }
#change back before next command
_pwd_color_preexec() { __PROMPT_PWD="%F{magenta}%~%f" }

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

#set screen/tmux title if not connected remotely
#if [ "$STY" != "" ]; then
_tmux_precmd() {
  #a bell, urgent notification trigger
  #echo -ne '\a'
  #title "`print -Pn "%~" | sed "s:\([~/][^/]*\)/.*/:\1...:"`" "$TERM $PWD"
  title "`print -Pn "%~" |sed "s:\([~/][^/]*\)/.*/:\1..:;s:\([^-]*-[^-]*\)-.*:\1:"`"
  echo -ne '\033[?17;0;127c'
}

_tmux_preexec() {
  local -a cmd; cmd=(${(z)1})
  executable=$cmd[1]
  case $executable:t in
    ssh|mosh|et) title "@$(echo $cmd[-1]|sed -E 's:.*@::;s:([a-zA-Z][^.]+)\..*$:\1:')" ;;
    sudo)        title "#${cmd[2]:t}"  ;;
    *=*)         title "${cmd[2]:t}"   ;;
    for)         title "()$cmd[7]"     ;;
    svn|git)     title "${cmd[1,2]}"   ;;
    make)        title "[${cmd[2]:-${PWD##*/}}]"   ;;
    *)           title "${executable:t}"   ;;
  esac
}

# reset cursor to a vertical bar
# CSI Ps SP q
# Set cursor style (DECSCUSR), VT520.
#   Ps = 0  -> blinking block.
#   Ps = 1  -> blinking block (default).
#   Ps = 2  -> steady block.
#   Ps = 3  -> blinking underline.
#   Ps = 4  -> steady underline.
#   Ps = 5  -> blinking bar (xterm).
#   Ps = 6  -> steady bar (xterm).
_reset_cursor() { printf "\e[6 q" }

#}}}

#{{{define magic function arrays
# typeset -ga preexec_functions precmd_functions chpwd_functions
autoload -Uz add-zsh-hook
add-zsh-hook precmd  _tmux_precmd
add-zsh-hook precmd  vcs_info
add-zsh-hook precmd  _reset_cursor
add-zsh-hook preexec _tmux_preexec
add-zsh-hook preexec _pwd_color_preexec
add-zsh-hook chpwd   _pwd_color_chpwd
add-zsh-hook chpwd   vcs_info
#}}}

# }}}

# 提示符 {{{
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*:*' formats           " %F{white}%K{black}%B%b%m%c%u%f%k%%b"
zstyle ':vcs_info:*:*' actionformats     " %F{white}%K{black}%B%b%m(%a)%c%u%f%k%%b"
zstyle ':vcs_info:*:*' stagedstr         "%F{green}*"
zstyle ':vcs_info:*:*' unstagedstr       "%F{red}*"
zstyle ':vcs_info:*:*' check-for-changes true
zstyle ':vcs_info:*:*' get-revision      true
zstyle ':vcs_info:git*+set-message:*'    hooks git-misc-n-abbr-master
function +vi-git-misc-n-abbr-master() {
    local ahead behind
    local -a gitstatus

    # for git prior to 1.7
    # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    (( $ahead )) && gitstatus+=( "+${ahead}" )

    # for git prior to 1.7
    # behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
    (( $behind )) && gitstatus+=( "-${behind}" )

    hook_com[misc]+=${(j:/:)gitstatus}

    # change branch name display to M for master and use revision when it is easier
    hook_com[branch]=${hook_com[branch]/#%master/M}
    [[ "${hook_com[branch]}" == *\~?? ]] && hook_com[branch]=${${hook_com[revision]}[1,6]}
}

if [ -z "$SSH_TTY" ]; then
    local host="%b%F{magenta}%m%f"
else
    local host="%b%U%F{magenta}%m%f%u"            # underline for remote hostname
fi
local user="%B%(!:%F{red}:%F{green})%n%b"       # red for root user name
local job="%1(j,%F{red}:%F{blue}%j,)%f"
local sym="%b%(?,%F{yellow},%F{red})%(!.#.>) %f"
PROMPT='$host $user $__PROMPT_PWD${vcs_info_msg_0_}$job $sym'
PROMPT2="$PROMPT%F{cyan}%_ %B%F{black}>%b%F{green}>%B%F{green}>%f%b "

# SPROMPT - the spelling prompt
SPROMPT="%F{yellow}zsh%f: correct '%F{red}%B%R%f%b' to '%F{green}%B%r%f%b' ? ([%F{cyan}Y%f]es/[%F{cyan}N%f]o/[%F{cyan}E%f]dit/[%F{cyan}A%f]bort) "

# }}}

# ZLE {{{
# 基本键绑定  {{{
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
# }}}

# 自定义widget {{{
#

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

# }}}
 
# }}}

# 其他额外软件 {{{

# FZF and friend, esc f to fzf for current command {{{
if ( _has fzf ); then
  # dirty hack for ubuntu/debian
  ( _has fd ) && FD_EXECUTABLE=fd || FD_EXECUTABLE=fdfind
  export FZF_DEFAULT_COMMAND="$FD_EXECUTABLE --type f"
  # molokai themed
  if [[ $- == *i* ]]; then
    # only set default opts when in interactive shell
    export FZF_DEFAULT_OPTS="
    --exact
    --algo=v1
    --info=inline
    --layout=reverse
    --height=40%
    --color fg:252,bg:233,hl:210,fg+:252,bg+:235,hl+:196,info:144,prompt:161,spinner:135,pointer:135,marker:118
    --preview-window=:hidden
    --bind '?:toggle-preview'
    "
  fi
  alias f=fzf

  # search history with fzf
  _fzf_history() {
    builtin fc -l -r -n 1 | fzf-tmux -p --prompt 'HISTORY > ' -e -q "$*"
  }
  # A completion fallback if something more specific isn't available.
  function _fzf_generic_find() {
    local cmd="$1"; shift 1
    $FD_EXECUTABLE . 2>/dev/null | fzf-tmux -p --prompt 'FILES > ' -q "$*" | xargs printf '%s %s\n' "$cmd"
  }

  # {{{ custom command completion with fzf, idea from whiteinge/dotfiles
  # Usage:
  #   <[empty cli]> - complete from shell history.
  #   <cmd> - complete from _fzf_<cmd> script or funciton output.
  #   <cmd> - falls back to generic file path completion.
  #
  # New completions can be added for a <cmd> by adding a shell function or
  # a shell script on PATH with the pattern _fzf_<cmd>. The script will be
  # invoked with the command name and any arguments as ARGV and should print the
  # full resulting command and any additions to stdout.
  fzf-completion() {
    setopt localoptions localtraps noshwordsplit noksh_arrays noposixbuiltins

    local tokens=(${(z)LBUFFER})
    local cmd=${tokens[1]}
    local cmd_fzf_match

    if [[ ${#tokens} -lt 1 ]]; then
      cmd_fzf_match=( '_fzf_history' )
    else
      # Filter (:#) the arrays of the names ((k)) Zsh function and scripts on
      # PATH and remove ((M)) entries that don't match "_fzf_<cmdname>":
      cmd_fzf_match=${(M)${(k)functions}:#_fzf_${cmd}}
      [[ ${#cmd_fzf_match} -eq 0 ]] && cmd_fzf_match=${(M)${(k)commands}:#_fzf_${cmd}}
      [[ ${#cmd_fzf_match} -eq 0 ]] && cmd_fzf_match=( '_fzf_generic_find' )
    fi

    zle -M "Gathering suggestions..."
    zle -R

    local result=$($cmd_fzf_match "${tokens[@]}")
    if [ -n "$result" ]; then
      LBUFFER="$result"
    fi

    zle reset-prompt
  }
  
  fzf-history-complete() {
    setopt localoptions localtraps noshwordsplit noksh_arrays noposixbuiltins
    local tokens=(${(z)LBUFFER})
    local result=$(_fzf_history "${tokens[@]}")
    if [ -n "$result" ]; then
      LBUFFER="$result"
    fi

    zle reset-prompt
  }

  fzf-view-file() {
    setopt localoptions localtraps noshwordsplit noksh_arrays noposixbuiltins
    zle reset-prompt

    result=$($FD_EXECUTABLE . 2>/dev/null | fzf-tmux -p --prompt 'FILES > ' -q "$*" | xargs printf '%s')
    if [ -n "$result" ]; then
      cmd="${PAGER:-less}"
      if ( _has lnav ) && [[ "$result" = *log* ]]; then
        cmd="lnav -R"
      fi
      LBUFFER="$cmd \"$result\""
      zle accept-line
    fi
  }

  zle -N fzf-completion
  zle -N fzf-history-complete
  zle -N fzf-view-file
  bindkey '\ef' fzf-completion
  bindkey '' fzf-history-complete
  bindkey '\er' fzf-history-complete
  bindkey '\el' fzf-view-file
  # }}}

  # {{{ wiki search and view
  wiki_dir=$HOME/wiki
  if [[ -d $wiki_dir ]]; then
    fzf-view-wiki() {
      setopt localoptions localtraps noshwordsplit noksh_arrays noposixbuiltins
      zle reset-prompt

      if _has bat; then
        local cmd="bat --style grid"
      else
        local cmd=less
      fi
      result=$( \
        gawk 'FNR < 3 && /^title:\s+/ {$1=""; idx=split(FILENAME, parts, "/"); print parts[idx]":",$0; nextfile}' $wiki_dir/*.md | \
        fzf-tmux -p --prompt 'WIKI > ' -q "$*" | \
        cut -d: -f1 | \
        xargs printf "$cmd $wiki_dir/%s" 
      )
      if [ -n "$result" ]; then
        LBUFFER="$result"
      fi
      zle accept-line
    }

    zle -N fzf-view-wiki
    bindkey '\e ' fzf-view-wiki
  fi
  # }}}
fi
# }}}

# zoxide for auto jump {{{
if _has zoxide; then
    eval "$(zoxide init zsh)"
fi
# }}}

# direnv {{{
if ( _has direnv ); then
  eval "$(direnv hook zsh)"
fi
# }}}

# kubernet {{{
if ( _has kubectl ); then
  # run: kubectl completion zsh > ~/.zfunctions/_kubectl
  alias k=kubectl
  compdef k=kubectl
fi
# }}}

# docker {{{
if ( _has docker ); then
  alias d=docker
  ( command -v _docker &>/dev/null ) && compdef d=docker
fi
if ( _has docker-compose ); then
  alias dc=docker-compose
  ( command -v _docker-compose &>/dev/null ) && compdef dc=docker-compose
fi
# }}}

# vim / nvim {{{
if ( _has nvim ); then
    export EDITOR='nvim' VISUAL='nvim' SUDO_EDITOR='nvim'
    alias vim='nvim'
else
    export EDITOR='vim' VISUAL='vim' SUDO_EDITOR='vim'
fi
# }}}

# 读入其他配置 {{{

if [[ -d $HOME/.zplug ]]; then
  # git clone https://github.com/zplug/zplug ~/.zplug
  source $HOME/.zplug/init.zsh
  [[ -f $HOME/.zshrc.plug ]] && source $HOME/.zshrc.plug
fi
[[ -f $HOME/.zshrc.$(hostname -s) ]] && source $HOME/.zshrc.$(hostname -s)
[[ -f $HOME/.zshrc.local ]]          && source $HOME/.zshrc.local

# }}}

typeset -U PATH
