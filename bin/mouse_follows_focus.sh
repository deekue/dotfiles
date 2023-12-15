#!/bin/bash
#
# h/t: https://www.reddit.com/r/i3wm/comments/5j11sd/more_mouse_warping/

window_geometry="$(xdotool getactivewindow getwindowgeometry)"
geometry="$(sed -nE '/^  Geometry: ([0-9]*x[0-9]*).*$/ s//\1/p' <<< "$window_geometry")"
position="$(sed -nE '/^  Position: ([0-9]*,[0-9]*).*$/ s//\1/p' <<< "$window_geometry")"

x_pos="${position%%,*}"
y_pos="${position##*,}"

x_geo="${geometry%%x*}"
y_geo="${geometry##*x}"

# warp mouse to middle of active window
x_warp=$(( x_pos + x_geo / 2 ))
y_warp=$(( y_pos + y_geo / 2 ))

xdotool getactivewindow mousemove "$x_warp" "$y_warp"

