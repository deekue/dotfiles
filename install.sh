#!/bin/sh -e

GIT_REPO=https://github.com/deekue/vim-go-ide
INSTALL_TO=~/src/vim-go-ide
LINKS="vimrc vim fonts bashrc bash_aliases bash_logout gitconfig profile screenrc lynxrc nethackrc tmux.conf"
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
  $ECHO git clone $GIT_REPO $INSTALL_TO
  $ECHO cd $INSTALL_TO
fi

# Initialize submodules
$ECHO git submodule update --init --recursive

# Install packages to build YCM
$ECHO sudo apt-get install build-essential cmake python-dev

# Set up YCM
cd $(dirname -- "$0")/vim/bundle/YouCompleteMe
$ECHO ./install.sh
#$ECHO ./install.sh --clang-completer # use this for C-family support
cd -

# install Go tools
$ECHO ./install_go_tools.sh

# Tabular wants exuberant-ctags
$ECHO sudo apt-get install exuberant-ctags

# Create symlinks
for f in $LINKS; do
  link_file_or_dir "$INSTALL_TO"/"$f" ~/."$f"
done

# update font cache
if [ -e $INSTALL_TO/fonts/* ] ; then
  $ECHO fc-cache -f -v
fi

# touch local override files
$ECHO touch ~/.vim/user.vim

