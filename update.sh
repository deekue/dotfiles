#!/bin/sh -ex
git submodule update --init --remote
git status
./install_go_tools.sh
