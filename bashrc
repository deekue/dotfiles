# ~/.bashrc: executed by bash(1) for non-login shells.
# Init {{{
# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

case "$(uname -s)" in
  Darwin)
    export PLATFORM=macos
    ;;
  Linux|linux)
    export PLATFORM=linux
    ;;
  *)
    unset PLATFORM
    ;;
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
if [[ "$PLATFORM" == "macos" ]] ; then
  SecretAgentSock="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
  if [[ -S "$SecretAgentSock" ]] ; then
    export SSH_AUTH_SOCK="$SecretAgentSock"
  fi
  ssh-add --apple-use-keychain
fi
# }}}
# enable colour, if available {{{
if inpath dircolors && term_in_dircolors ; then
  if [[ "$TERM" == "alacritty" ]] ; then
    # alacritty isn't in ncurses lib yet
    eval "$(TERM=xterm-256color dircolors -b)"
  else
    eval "$(dircolors -b)"
  fi
  if ls --version 2>&1 > /dev/null ; then  
    # GNU ls
    alias ls='ls --color=auto'
  fi
  export LESS="R"
fi
if [[ "$PLATFORM" == "macos" ]] ; then
  export CLICOLOR=yknot
fi
# }}}

# ENV {{{

export TZ="America/Los_Angeles"
export EDITOR=nvim
#export PRINTER=something
#export LPDEST=$PRINTER
export GREP_COLOR=auto

# python virtualenv
export WORKON=~/.virtualenvs

export BC_ENV_ARGS="$HOME/.config/bc"

export ZK_NOTEBOOK_DIR="$HOME/src/zk"

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

if [[ -n "$PS1" ]]; then
  if inpath dircolors && term_in_dircolors ; then
    PS1='\[\e[01;32m\]\t\[\e[00m\] \[\e[01;36m\]\u@\h\[\e[00m\]:\[\e[01;34m\]$(abbrev_pwd)\[\e[00m\]\$ '
    if [[ "$(type -t __git_ps1)" == "function" ]]; then
       PS1='\[\e[01;32m\]\t\[\e[00m\] \[\e[01;36m\]\u@\h\[\e[00m\]:\[\e[01;34m\]$(abbrev_pwd)\[\e[00m\]\[\e[01;37m\]$(__git_ps1)\[\e[00m\]\$ '
    fi
  else
    PS1='\t \u@\h:$(abbrev_pwd)\$ '
    if [[ "$(type -t __git_ps1)" == "function" ]]; then
      PS1='\t \u@\h:$(abbrev_pwd)$(__git_ps1)\$ '
    fi
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
inpath lesspipe.sh && eval "$(lesspipe.sh)"

add_bin_path pre "$HOME/bin"
add_bin_path post "$HOME/Library/Python/3.7/bin"

# go-lang
[ -d $HOME/src/go ] && export GOPATH="$HOME/src/go"
add_bin_path pre /usr/local/go/bin
add_bin_path pre "$HOME/src/go/bin"

# setup AWS
[ -r ~/.aws/bashrc ] && . ~/.aws/bashrc

# Google Cloud SDK.
add_bin_path pre "$HOME/tmp/google-cloud-sdk/bin"
# The next line enables bash completion for gcloud.
[ -r $HOME/tmp/google-cloud-sdk/arg_rc ] && source $HOME/tmp/google-cloud-sdk/arg_rc

# locally installed pip binaries
add_bin_path pre "$HOME/.local/bin"

# strap:straprc:begin
#[ -r "$HOME/.strap/etc/straprc" ] && . "$HOME/.strap/etc/straprc"
# strap:straprc:end

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash

inpath gh && eval "$(gh completion -s bash)"

# screen/tmux init {{{

# screen/pane auto config {{{
if [[ "${TERM:0:6}" == "screen" ]]; then
  screen_init
elif [ -n "$TMUX" ] ; then
  tmux_init
fi
# }}}

if [[ -r "$HOME/.bashrc.$HOSTNAME" ]] ; then
  . "$HOME/.bashrc.$HOSTNAME"
fi

# SSH sessions {{{
if [[ -n "$SSH_TTY" ]] ; then
  # use ssh-agent from outside the screen session {{{
  SCREEN_SSH_AUTH_SOCK="$HOME/.ssh/screen.auth.sock"
  case "$TERM" in
    screen*)
      if [ -L "$SCREEN_SSH_AUTH_SOCK" ] ; then
        export SSH_AUTH_SOCK="$SCREEN_SSH_AUTH_SOCK"
      fi
      ;;
    *)
      if [[ -n "$TMUX" ]] ; then
        if [ -L "$SCREEN_SSH_AUTH_SOCK" ] ; then
          export SSH_AUTH_SOCK="$SCREEN_SSH_AUTH_SOCK"
        fi
      else
        # not in a screen/tmux session, if the socket exists symlink it
        if [ -n "$SSH_AUTH_SOCK" ] ; then
          ln -sf "$SSH_AUTH_SOCK" "$SCREEN_SSH_AUTH_SOCK"
        fi
      fi
      ;;
  esac # }}}
  # Tmux/Screen auto start {{{
  if ! type tmux 2>/dev/null ; then
    # no tmux :(
    if [ "${TERM:0:6}" != "screen" ]; then
      # set window title
      echo -ne "\033]0;${USER}@${HOSTNAME%%.*}\007"

      # connect to session "main" or create a new one if not found
      screen -x -s main
      exit
    fi
  elif [[ -z "$TMUX" ]] ; then
    # set window title
    echo -ne "\033]0;${USER}@${HOSTNAME%%.*}\007"

    # connect to session "main" or create a new one if not found
    tmux new -A -s main
    exit # exit on detach or exit
  fi  # }}}
fi
# }}}
# }}}

# vim:set foldmethod=marker:
