
# MacOS {{{
if [[ "$(uname -a)" == "Darwin" ]]; then
  alias xclip=pbcopy
  alias tf=terraform

  function get_bundle {
    /usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "/Applications/${1^}.app/Contents/Info.plist"
  }
fi
# }}}

function pussh_term {
  : "${1:?Usage: pussh_term host}"
  infocmp | ssh "$@" 'tic -x /dev/stdin'
}

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

function inpath {
  type "$@" > /dev/null 2>&1
}

function term_in_dircolors {
  if [[ "$TERM" == "alacritty" ]] ; then
    true
  else
    # TODO fix this, works poorly.  dircolors db uses globbing not regex
    echo "${1:-$TERM}" | grep -qf <(dircolors --print-database | sed -ne '/^TERM / s///p')
  fi
}

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

function pussh_term {
  : "${1:?Usage: pussh_term host}"
  infocmp | ssh "$@" 'tic -x /dev/stdin'
}

function check_zerotier() {
  if ! zerotier-cli info | grep -q ONLINE ; then
    echo "starting ZeroTier"
    sudo service zerotier-one start
  fi
}

function chiron() {
  gcloud compute --project "perfect-trilogy-461" ssh --zone "us-central1-a" "chiron"
}

# Backups {{{
function backup() {
  $HOME/bin/duplicacy -log backup -stats
}
function backup-offsite() {
  check_zerotier
  $HOME/bin/duplicacy -log copy -id chelone-home -to metis -threads ${1:-5}
}
# }}}

# Screen setup {{{
function screen_init() {

  local SCREEN=$1

  if [ -z "$SCREEN" ] ; then
    TTY=`/usr/bin/tty | cut -f3- -d/`
    SCREEN=$(who | grep "$TTY" | sed -n 's/^.*:S\.\([0-9]*\))$/\1/p')
  fi

  case $SCREEN in
    0)
      irssi
      ;;
    1)
      cd /some/where
      ;;
    2)
      cd ~/doc/
      ;;
    3)
      cd /some/where/else
      ;;
    4)
      cd /some/where
      export PATH=$PATH:/home/build/
      export PATH=/foo
  esac
}
# }}}
# Tmux setup {{{
function tmux_init() {

  local PANE="${1:-$TMUX_PANE}"

  case $PANE in
    %0)
      irssi
      ;;
    %1)
      #cd /some/where
      ;;
    %2)
      #cd /some/where/else
      ;;
    %3)
      cd /some/where
      export PATH=$PATH:/home/build/
      export P4DIFF='/usr/bin/diff -u'
      ;;
  esac
}
# }}}

if [[ -r "$HOME/.bash_aliases.$HOSTNAME" ]] ; then
  source "$HOME/.bash_aliases.$HOSTNAME"
fi

# vim:set foldmethod=marker:

