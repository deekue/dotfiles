#!/bin/sh -ex
git submodule update --init --remote
git status
$(dirname -- "$0")/install_go_tools.sh
