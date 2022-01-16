# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" -a -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
#case "$TERM" in
#xterm-color)
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    #;;
#*)
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    #;;
#esac

# Comment in the above and uncomment this below for a color prompt
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Dynamic xterm title as user@host:dir
if [[ -z $SSH_CONNECTION ]]; then
    case "$TERM" in
        xterm*|rxvt*)
            PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
            ;;
        screen)
            PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
            ;;
        *)
            export TERM=xterm
            ;;
    esac
else
    export TERM=xterm
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

# completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ] && (command -v dircolors &>/dev/null ); then
    [[ -f $HOME/.lscolor256 ]] && eval $(dircolors -b $HOME/.lscolor256) || eval $(dircolors -b)
    alias ls='ls --color=auto'
fi

# some more ls aliases
alias ll='ls -l'

bind '"": history-search-backward'
bind '"": history-search-forward'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
   . /etc/bash_completion
fi

#if [ "$TERM" = "linux" ]
#then
#we're on the system console or maybe telnetting in
#export PS1="\[\e[32;1m\]\u@\H:\[\e[36;1m\]\w\[\e[33;1m\]$ \[\e[0m\]"
#else
#we're not on the console, assume an xterm
#export PS1="\[\e]2;\u@\H \w\a\[\e[32;1m\]\u@\H:\[\e[36;1m\]\w\[\e[33;1m\]$ \[\e[0m\]"
#fi

export PATH=$PATH:$HOME/bin

export PAGER=less LESS="-M -i -R --shift 5" LESSCHARSET=utf-8 READNULLCMD=less
export LESS_TERMCAP_md=$'\e[1;34m'      #bold
export LESS_TERMCAP_mb=$'\e[1;33m'      #blinking
export LESS_TERMCAP_me=$'\e[m'          #end all modes
export LESS_TERMCAP_so=$'\e[01;7;34m'   #search highlight, standout mode
export LESS_TERMCAP_se=$'\e[m'          #end standout mode
export LESS_TERMCAP_us=$'\e[1;32m'      #underlining
export LESS_TERMCAP_ue=$'\e[m'          #end underlining

# add Intel Compiler environment variables
#source /opt/intel/fc/9.1.036/bin/ifortvars.sh
#source $HOME/.context_env /home/roylez/soft/ConTeXt/tex
if (command -v vim &>/dev/null ); then
    export EDITOR=vim VISUAL=vim
else
    export EDITOR=vi VISUAL=vi
fi

