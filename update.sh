#!/bin/sh -ex
git submodule foreach git pull origin master
git submodule update
git submodule init
./install_go_tools.sh
