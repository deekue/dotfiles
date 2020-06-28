# ~/.bashrc: executed by bash(1) for non-login shells.
# Init {{{
# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# Source global definitions
if [ -f /etc/bashrc ] ; then
  . /etc/bashrc
fi

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -f /usr/local/etc/profile.d/bash_completion.sh ]; then
    . /usr/local/etc/profile.d/bash_completion.sh
  fi
fi

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# }}}

# Security stuff (eg. ssh etc) {{{
if uname -a | grep -q Darwin ; then
  ssh-add -K
fi
# }}}
# enable colour, if available {{{
if inpath dircolors && term_in_dircolors ; then
  eval "$(dircolors -b)"
  if ls --version 2>&1 > /dev/null ; then  
    # GNU ls
    alias ls='ls --color=auto'
  fi
fi
if uname -a | grep -q Darwin ; then
  export CLICOLOR=yknot
fi
# }}}

# ENV {{{

export TZ="America/Los_Angeles"
export EDITOR=vim
#export PRINTER=something
#export LPDEST=$PRINTER
export GREP_COLOR=auto

# python virtualenv
export WORKON=~/.virtualenvs

export BC_ENV_ARGS="$HOME/.config/bc"

# }}}

# History {{{
shopt -s histappend histreedit histverify
export HISTCONTROL='ignoredups:ignorespace:ignoreboth'
export HISTFILESIZE=10000
export HISTIGNORE='&:ls:[bf]g:exit'
export HISTSIZE=1000
export HISTTIMEFORMAT="%F %T "
#export PROMPT_COMMAND="[ $(($(date +%M) % 5)) -gt 4 ] && history -a"

# }}}

# Prompt {{{
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ] ; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# dynamic titles for screen
# \033k<title>\033\\ is an escape sequence that screen uses to set window titles
# \001 and \002 delimit a sequence of non-printing characters to bash so this
# doesn't screw things up (equivalent to \[ and \] but will work even when
# substituted into PS1)
title_escape() {
  case "$TERM" in
    screen*) printf '\001\033k%s\033\\\002' "$1";;
    *) echo ""
  esac
}

# stuff for abbreviating PS1 for some paths
# with title_escape calls
abbrev_pwd() {
  case "$PWD" in
    $HOME|$HOME/*)
      printf "~%s%s" "$(title_escape \~)" "${PWD#$HOME}"
      ;;
    *)
      printf "%s%s" "$PWD" "$(title_escape -)"
      ;;
  esac
}

if [[ -n "$PS1" ]]; then
  if type dircolors > /dev/null 2>&1 \
    && echo "$TERM" | grep -qf <(dircolors --print-database | sed -ne '/^TERM/ s///p'); then
    # TODO detect color on MacOS?
    PS1='\[\e[01;32m\]\t \u@\h\[\e[00m\]:\[\e[01;34m\]$(abbrev_pwd)\[\e[00m\]$(__git_ps1)\$ '
  else
    PS1='\t \u@\h:$(abbrev_pwd)$(__git_ps1)\$ '
  fi
  PS1="${debian_chroot:+($debian_chroot)}$PS1"
fi

# If this is an xterm set the title
case "$TERM" in
xterm*|rxvt*|alacritty)
    PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND};}"'echo -ne "\033]0;${USER}@${HOSTNAME%%.*}: $(abbrev_pwd)\007"'
    ;;
*)
    ;;
esac

# }}}

# enable vi keys
set -o vi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

add_bin_path pre "$HOME/bin"

# go-lang
[ -d $HOME/src/go ] && export GOPATH="$HOME/src/go"
add_bin_path pre /usr/local/go/bin
add_bin_path pre "$HOME/src/go/bin"

# setup AWS
[ -r ~/.aws/bashrc ] && . ~/.aws/bashrc

# Google Cloud SDK.
add_bin_path pre /home/apathy/tmp/google-cloud-sdk/bin
# The next line enables bash completion for gcloud.
#source /home/apathy/tmp/google-cloud-sdk/arg_rc


# strap:straprc:begin
[ -r "$HOME/.strap/etc/straprc" ] && . "$HOME/.strap/etc/straprc"
# strap:straprc:end

# screen/tmux init {{{

# screen/pane auto config {{{
if [ "${TERM:0:6}" == "screen" ]; then
  screen_init
elif [ -n "$TMUX" ] ; then
  tmux_init
fi
# }}}

# Tmux/Screen auto start for SSH sessions {{{
if [[ -n "$SSH_TTY" ]] ; then
  # TODO detect screen vs tmux
  #if [ "${TERM:0:6}" != "screen" ]; then
  if ! type tmux 2>/dev/null ; then
    echo tmux not found, sadness ensues
  elif [[ -z "$TMUX" ]] ; then
    # set window title
    echo -ne "\033]0;${USER}@${HOSTNAME%%.*}\007"

    # connect to session "main" or create a new one if not found
    tmux new -A -s main
    exit # exit on detach or exit
  fi
fi
# }}}
# }}}

# vim:set foldmethod=marker:
