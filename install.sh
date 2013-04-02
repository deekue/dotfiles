#!/bin/sh -e

INSTALL_TO=~/dotfiles
ECHO=""

while getopts "n" VALUE "$@"; do
  if [ "$VALUE" = "n" ]; then
    echo "Running in dryrun mode."
    ECHO=echo
  fi
done

warn() {
    echo ERROR: "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

link_file_or_dir() {
  src="$1"
  dest="$2"
  if [ ! -e $dest ]; then
    echo "$dest doesn't exist, linking."
    $ECHO ln -sfT "$src" "$dest";
  elif [ -h $dest ]; then
    echo "$dest is a symlink, relinking."
    $ECHO ln -sfT "$src" "$dest";
  else
    warn "$dest already exists and is not a symlink. Skipping."
  fi
}

if [ -e $INSTALL_TO ]; then
  $ECHO cd $INSTALL_TO
  $ECHO git pull
else
  $ECHO git clone https://github.com/hobeone/dotfiles.git $INSTALL_TO
  $ECHO cd $INSTALL_TO
fi
# Initialize submodules
$ECHO git submodule init
$ECHO git submodule update

LINKS="vimrc vim oh-my-zsh fonts Xmodmap Xresources zshrc tmux.conf xscreensaver"
for f in $LINKS; do
  link_file_or_dir "$INSTALL_TO"/"$f" ~/."$f"
done

$ECHO fc-cache -f -v

$ECHO touch ~/.vim/user.vim
$ECHO touch ~/.zshrc.local

$ECHO mkdir -p ~/.config
$ECHO mkdir -p ~/.config/Terminal
link_file_or_dir "$INSTALL_TO"/config/Terminal/terminalrc ~/.config/Terminal/terminalrc
link_file_or_dir "$INSTALL_TO"/config/openbox ~/.config/openbox


if [ ! -e ~/bin/keyserver ]; then
  $ECHO mkdir -p ~/bin
  $ECHO wget -O ~/bin/keyserver.bz2 https://keysocket-server.googlecode.com/files/keyserver.bz2
  $ECHO bunzip2 ~/bin/keyserver.bz2
	chmod 755 ~/bin/keyserver
fi

