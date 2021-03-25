#!/usr/bin/env sh
#
# quick hack to parse Remontoire style comments and output JSON

CFG_FILE="${1:-~/.skhdrc}"

items="$(cat $CFG_FILE \
  | sed -nE -e 's/^## (.*) \/\/ (.*) \/\/ (.*) ##.*$/{"category": "\1", "action": "\2", "keybinding": "\3"},/p')"

echo "[ ${items%,} ]"
