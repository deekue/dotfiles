# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="afowler"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git ruby rails rsync rvm bundler cp history-substring-search themes npm bower golang)

source $ZSH/oh-my-zsh.sh

typeset -U path
path=(~/bin /bin /sbin /usr/local/bin /usr/sbin /usr/local/sbin /usr/bin)
# Extend PATH
path=( $path /usr/local/scripts )
path=( $path /usr/local/go/bin )
path=( $path $HOME/go/bin )
path=( $path /usr/X11R6/bin )
path=( $path $HOME/npm $HOME/npm/bin $HOME/npm/lib )

setopt AUTO_PUSHD
setopt nobeep                  # i hate beeps
unsetopt auto_menu              # don't cycle completions
setopt nocheckjobs             # don't warn me about bg processes when exiting
setopt nohup                   # and don't kill them, either
setopt listpacked              # compact completion lists
setopt listtypes               # show types in completion
#setopt extendedglob            # weird & wacky pattern matching - yay zsh!
unsetopt complete_in_word          # not just at the end
setopt always_to_end             # when complete from middle, move cursor
unsetopt correct                 # spelling correction
unsetopt correct_all                 # spelling correction
#setopt nopromptcr              # don't add \n which overwrites cmds with no \n
#setopt histverify              # when using ! cmds, confirm first
setopt interactivecomments     # escape commands so i can use them later
#setopt recexact                # recognise exact, ambiguous matches
#setopt printexitvalue          # alert me if something's failed

setopt chaselinks

setopt shwordsplit

# Don't complete any usernames except root and me
complete_users=(root $USERNAME)
zstyle ':completion:*' users $complete_users

# Only complete what I've typed, no substring matches.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

##############################################################################
# history
##############################################################################
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt hist_ignore_dups
setopt appendhistory
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
#setopt SHARE_HISTORY

alias loadhistory="fc -RI"

##############################################################################
# basic env
##############################################################################
unset MAIL
export MAILDIR="~/Maildir/"

export PAGER=less
export EDITOR="vim"

if [[ $USER == 'root' ]] then
  PS1="%{${fg[red]}%}%n@%m:%{${fg[cyan]}%}%~%{${fg[default]}%}#"
else
  PS1="%{${fg[green]}%}%n@%m:%{${fg[cyan]}%}%~%{${fg[default]}%}>"
fi

case $TERM in
  xterm*|rxvt|Eterm)
    precmd () {print -Pn "\e]0;%n@%M: %~\a"}
  ;;
esac

##############################################################################
# command aliases
##############################################################################
# If running interactively, then:
if [ "$PS1" ]; then
  alias ls='ls --color=auto'
  eval `dircolors`
fi

alias par="parchive"
compdef '_files -g "*.(par|PAR)2"' par2
compdef '_files -g "*.rar"' rar

alias irb='irb -r irb/completion'
alias ri='ri --format ansi'

alias vim='vim -X -o -u $HOME/.vimrc "$@"'
alias gvim='gvim --disable-sound --sm-disable --oaf-private -o -u $HOME/.vimrc -geom 80x24 "$@"'

alias e=gvim

alias tmux='tmux -2'

##############################################################################
# command configuration
##############################################################################
if [ -e $HOME/bin/lesspipe.sh ]; then
    export LESSOPEN="|$HOME/bin/lesspipe.sh %s" # preprocess compressed files
fi

LESS='-M-Q'
LESSEDIT="%E ?lt+%lt. %f"
LESSCHARDEF=8bcccbcc13b.4b95.33b. # show colours in ls -l | less
export LESS LESSEDIT LESSCHARDEF

export CVS_RSH=ssh
export RSYNC_RSH=ssh

##############################################################################
# helper functions
##############################################################################
psgrep()
{
  ps aux | grep $1 | grep -v "grep $1"
}

hgrep()
{
  history | grep $1 | grep -v "grep $1"
}

pskill()
{
        local signal="TERM"
        if [[ $1 == "" || $3 != "" ]]; then
                print "Usage: pskill search_term [signal]" && return 1
        fi
        [[ $2 != "" ]] && signal=$2
        set -A pids $(command ps -elf | grep $1 | grep -v "grep $1" | \
                        awk '{ print $4 }')
        if [[ ${#pids} -lt 1 ]]; then
                print "No matching processes for $1" && return 1
        fi
        if [[ ${#pids} -gt 1 ]]; then
                print "${#pids} processes matched: $pids"
                read -q "?Kill all? [y/n] " || return 0
        fi
        if kill -$signal $pids; then
                echo "Killed $1 pid $pids with SIG$signal"
        fi
}


compdef _files -g "*" scp

export GOPATH=$HOME/go

if [[ -e ~/.zshrc.local ]]; then
	source ~/.zshrc.local
fi
