#!/bin/sh -ex
git submodule init
git submodule update --recursive
#git submodule foreach git pull origin master
#git submodule update
./install_go_tools.sh
