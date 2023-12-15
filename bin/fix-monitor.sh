#!/bin/bash
#
# sometimes the right quarter of the screen is black after docking
# changing refresh rate clears it

output="$( xrandr -q | sed -nE '/^(.*) connected primary .*$/ s//\1/p')"

# assumes highest res is active, could search for active instead
mapfile -t modeline \
  < <( xrandr -q | sed -nE '/^.* connected primary /{n;p}' | fmt -1)
mode="${modeline[0]// }"

for rate in "${modeline[@]:1}" ; do
  rate="${rate// }"
  if [[ "$rate" =~ [0-9.]*\* ]] ; then
    active_rate="${rate/\*/}"
  else
    alt_rate="$rate"
    if [[ -n "$active_rate" ]] ; then
      break
    fi
  fi
done

if [[ -n "$active_rate" ]] && [[ -n "$alt_rate" ]] ; then
  xrandr --output "$output" --mode "$mode" --rate "$alt_rate"
  sleep 2
  xrandr --output "$output" --mode "$mode" --rate "$active_rate"
else
  echo -e "two refresh rates not found for mode $mode\n${modeline[@]}" >&2
  exit 1
fi

