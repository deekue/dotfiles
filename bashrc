# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
if echo $TERM | grep -qf <(dircolors -p | sed -ne '/^TERM/ s/^TERM //p') ; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1)\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Comment in the above and uncomment this below for a color prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    #alias dir='ls --color=auto --format=vertical'
    #alias vdir='ls --color=auto --format=long'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

function add_bin_path {
  local where="$1"
  local new_bin_path="$2"

  [ -d "$new_bin_path" ] || return 1
  if [ -n "${PATH##*${new_bin_path}}" -a -n "${PATH##*${new_bin_path}:*}" ]; then
    case "$where" in
      pre)
        export PATH=${new_bin_path}:$PATH
        ;;
      post)
        export PATH=$PATH:${new_bin_path}
        ;;
      *)
        echo "Usage: add_bin_path <pre|post> <path>" >&2
        return 1
        ;;
    esac
  fi
}

add_bin_path pre "$HOME/bin"

# git
export GIT_AUTHOR_NAME="Daniel Quinlan"
export GIT_COMMITTER_NAME="Daniel Quinlan"
export GIT_COMMITTER_EMAIL=daniel@chaosengine.net
export GIT_AUTHOR_EMAIL=daniel@chaosengine.net

export EDITOR=vim

# setup AWS
#. ~/.aws/bashrc

# go-lang
[ -d $HOME/src/go ] && export GOPATH=$HOME/src/go
add_bin_path pre /usr/local/go/bin
add_bin_path pre $HOME/src/go/bin

# The next line updates PATH for the Google Cloud SDK.
add_bin_path pre /home/danielq/tmp/google-cloud-sdk/bin

# The next line enables bash completion for gcloud.
#source /home/danielq/tmp/google-cloud-sdk/arg_rc

# python virtualenv
export WORKON=~/.virtualenvs

export BC_ENV_ARGS="$HOME/.config/bc"

