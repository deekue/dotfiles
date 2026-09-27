#!/bin/bash

DEBUG=
mkdir -p ~/.config

main_dots=(
  bash*
  config/bc
  dircolors
  git*
#  SpaceVim.d
  tmux.conf
  vim*
)

dev_dots=(
  config/gh
  config/git
  config/yamllint
  jqp.yaml
  markdownlint.json
)

x_dots=(
  config/regolith3
  Xresources
)

declare -n list="${1:-main}_dots"

for file in "${list[@]}" ; do
  dest="$HOME/.$file" 
  if [[ ! -L "$dest" && -f "$dest" ]] ; then 
    $DEBUG install --backup=t -T "$dest" "${dest}.orig" 
  fi 
  $DEBUG ln -sviT "$(pwd)/$file" "$dest"
done
