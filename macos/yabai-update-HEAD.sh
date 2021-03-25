#!/bin/sh
# https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(from-HEAD)#updating-to-latest-head

set -eEuo pipefail

# set codesigning certificate name here (default: yabai-cert)
export YABAI_CERT="${YABAI_CERT:-yabai-cert}"

# stop yabai
brew services stop koekeishiya/formulae/yabai

# reinstall yabai
brew reinstall koekeishiya/formulae/yabai
codesign -fs "${YABAI_CERT}" "$(brew --prefix yabai)/bin/yabai"

# reinstall the scripting addition
sudo yabai --uninstall-sa
sudo yabai --install-sa

# start yabai
brew services start koekeishiya/formulae/yabai

# load the scripting addition
killall Dock
