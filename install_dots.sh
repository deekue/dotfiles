#!/bin/bash

mkdir -p ~/.config

for a in bash_aliases bashrc tmux.conf git* SpaceVim.d config/bc ; do
  dest="$HOME/.$a" 
  if [[ -f "$dest" ]] ; then 
    install --backup=t -T "$dest" "${dest}.orig" 
  fi 
  ln -svi `pwd`/$a "$dest" 
done
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


