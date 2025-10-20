#!/usr/bin/env bash

# MacOS {{{
if [[ "$PLATFORM" == "macos" ]] ; then
  alias xclip=pbcopy
  alias anpaste='pbpaste | xargs Library/Android/sdk/platform-tools/adb shell input text'
  alias lsregister='/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister'

  function get_bundle {
    /usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "/Applications/${1^}.app/Contents/Info.plist"
  }

  fix_mosh_server() {
      local fw='/usr/libexec/ApplicationFirewall/socketfilterfw'
      local mosh_sym mosh_abs
      mosh_sym="$(command -v mosh-server)"
      mosh_abs="$(greadlink -f "$mosh_sym")"
  
      sudo "$fw" --setglobalstate off && \
      sudo "$fw" --add "$mosh_sym" && \
      sudo "$fw" --unblockapp "$mosh_sym" && \
      sudo "$fw" --add "$mosh_abs" && \
      sudo "$fw" --unblockapp "$mosh_abs" && \
      sudo "$fw" --setglobalstate on
  }
fi
# }}}

# Linux specific {{{
if [[ "$PLATFORM" == "Linux" ]]; then
  function iwif {
    ip -brief link \
      | sed -En '/^(wl[^[:space:]]+)[[:space:]]+.*$/ s//\1/p'
  }
fi
# }}}

# Chrome shortcuts {{{
export GOOGLE_CHROME=google-chrome-unstable
if command -v "${GOOGLE_CHROME}" > /dev/null ; then
#export GOOGLE_CHROME_PROFILE=
  function gmail {
    $GOOGLE_CHROME --app=https://gmail.com --name gMail
  }
  function gcal {
    $GOOGLE_CHROME --app=https://calendar.google.com --name "gCalendar"
  }
  function gchat {
    $GOOGLE_CHROME --app=https://hangouts.google.com --name "gChat"
  }
  function gmeet {
    $GOOGLE_CHROME --app=https://meet.google.com --name "gMeet"
  }
  function gvoice {
    $GOOGLE_CHROME --app=https://hangouts.google.com --name "gVoice"
  }
fi
# }}}

function add_bin_path {
  local -r where="$1"
  local -r new_bin_path="$2"
  local -r force="$3"

  [ -d "$new_bin_path" ] || return 1
  if [ -n "$force" ] || [[ ! "$PATH" =~ (^${new_bin_path}:|:${new_bin_path}:|:${new_bin_path}$) ]]; then
    case "$where" in
      pre)
        export PATH="${new_bin_path}:$PATH"
        ;;
      post)
        export PATH="$PATH:${new_bin_path}"
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
    echo "${1:-$TERM}" | grep -qf <(dircolors --print-database | sed -ne 's/\*/.*/g; /^TERM / s///p')
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
    "$HOME"|$HOME/*)
      printf "~%s%s" "$(title_escape \~)" "${PWD#"$HOME"}"
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

# Yubikey  {{{
function yk_otp_toggle {
  if ykman config usb --list | grep -qi otp ; then
    ykman config usb --enable otp
  else
    ykman config usb --disable otp
  fi
}
# }}}

function chiron() {
  gcloud compute --project "perfect-trilogy-461" ssh --zone "us-central1-a" "chiron"
}

# fzf {{{
if inpath fzf && inpath rg && inpath bat ; then
  # ripgrep->fzf->vim [QUERY]
  function rfv {
    local RELOAD OPENER

    RELOAD='reload:rg --column --color=always --smart-case {q} || :'
    # shellcheck disable=SC2016
    OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
              vim {1} +{2}     # No selection. Open the current line in Vim.
            else
              vim +cw -q {+f}  # Build quickfix list for the selected items.
            fi'
    fzf --phony --ansi --multi \
        --bind "start:$RELOAD" --bind "change:$RELOAD" \
        --bind "enter:become:$OPENER" \
        --bind "ctrl-o:execute:$OPENER" \
        --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
        --delimiter : \
        --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
        --preview-window '~4,+{2}+4/3,<80(up)' \
        --query "$*"
  }
else
  function rfv {
    echo "rfv requires fzf, rg, and bat to be installed"
    return 1
  }
fi
# }}}
# History {{{
# simple search across all per-window history files
function ahistory {
  # TODO find a parser for the date lines
  grep -hv "^#" "$HOME/.bash_history"*
}
function ahgrep {
  if inpath fzf ; then
    ahistory \
      | fzf \
          --height=40% \
          --layout=reverse \
          ${1:+--query="$*"} \
          --border
  else
    ahistory | grep "$*"
  fi
}
# }}}
# date/time {{{
alias utc='date -u --iso-8601=seconds'
# }}}
# dns.toys {{{
function dy {
  dig +noall +answer +additional "${1:-help}" @dns.toys
}
# }}}
# weather {{{
export CITY="San Francisco"
function weather {
  local location="$*"
  location="${location:-$CITY}"
  curl -fsSL "wttr.in/${location// /%20}?m1nF"
}
function forecast {
  local location="$*"
  location="${location:-$CITY}"
  curl -fsSL "wttr.in/${location// /%20}?mnF"
}
function moon {
  local location="$*"
  location="${location:-$CITY}"
  curl -GfsSL ${location:+--data-urlencode "+$location"} "wttr.in/Moon"
}
# }}}

# git {{{
function cdgr {
  cd "$(git rev-parse --show-toplevel)/${1:-}" || return 1
}
alias gr='git rev-parse --show-toplevel'
# }}}
# k8s {{{
alias k='kubectl ${K8S_NAMESPACE:+--namespace $K8S_NAMESPACE}'
complete -F __start_kubectl k
function kpod {
  #k -n "${1:?Usage: kpod namespace}" get pods -o jsonpath='{.items[0].metadata.name}'
  k get pods -o jsonpath='{.items[0].metadata.name}'
}

function kex {
  #k -n "${1:?Usage: kex namespace}" exec -it "$(kpod $1)" -- bash
  k exec -it "$(kpod)" -- bash
}

function kcn {
  local -r new_namespace="${1:?arg1 is new k8s namespace}"

  export K8S_NAMESPACE="$new_namespace"
}

function __k8s_ps1 {
  if [[ -n "${K8S_NAMESPACE}" ]] ; then
    echo -n "(${K8S_NAMESPACE})"
  fi
}

#export PS1='[\u@\h \W]$(__k8s_ps1)\$ '
# }}}

# Backups {{{
function backup() {
  "$HOME/bin/duplicacy" -log backup -stats
}
function backup-offsite() {
  local -r threads="${1:-5}"
  check_zerotier
  "$HOME/bin/duplicacy" -log copy -id chelone-home -to wasabi -threads "$threads"
}
# }}}

# Screen setup {{{
function screen_init() {
  local window="${1:-}"
  local this_tty

  if [[ -z "$window" ]] ; then
    this_tty="$(/usr/bin/tty | cut -f3- -d/)"
    window="$(who | grep "$this_tty" | sed -En 's/^.*:S\.([0-9]*)\)$/\1/p')"
  fi

  case "$window" in
    0)
      #irssi
      ;;
    1)
      #cd /some/where
      ;;
    2)
      #cd ~/doc/
      ;;
    3)
      #cd /some/where/else
      ;;
    4)
      #cd /some/where
      #export PATH=$PATH:/home/build/
  esac
}
# }}}
# Tmux setup {{{
function tmux_init() {

  local PANE="${1:-$TMUX_PANE}"

  case $PANE in
    %0)
      #irssi
      ;;
    %1)
      #cd /some/where
      ;;
    %2)
      #cd /some/where/else
      ;;
    %3)
      #cd /some/where
      #export PATH=$PATH:/home/build/
      #export P4DIFF='/usr/bin/diff -u'
      ;;
  esac
}
# }}}

if [[ -r "$HOME/.bash_aliases.$HOSTNAME" ]] ; then
  # shellcheck disable=SC1090
  source "$HOME/.bash_aliases.$HOSTNAME"
fi

# vim:set foldmethod=marker:

