#!/bin/sh -ex

INSTALL_TO=~/

warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

[ -e "$INSTALL_TO/vimrc" ] && die "$INSTALL_TO/vimrc already exists."
[ -e "~/.vim" ] && die "~/.vim already exists."
[ -e "~/.vimrc" ] && die "~/.vimrc already exists."

mkdir -p "$INSTALL_TO"
cd "$INSTALL_TO"
git clone git://github.com/hobeone/vimrc.git
cd vimrc

# Download vim plugin bundles
git submodule init
git submodule update

# Symlink ~/.vim and ~/.vimrc
ln -s "$INSTALL_TO/vimrc/vimrc" ~/.vimrc
ln -s "$INSTALL_TO/vimrc/vim" ~/.vim
touch ~/.vim/user.vim

echo "Installed and configured .vim, have fun."
