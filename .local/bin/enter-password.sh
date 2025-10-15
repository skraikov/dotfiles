#!/bin/bash

# where to find xdotool keykodes: https://gitlab.com/nokun/gestures/-/wikis/xdotool-list-of-key-codes

gopass ls --flat | rofi -dmenu | xargs --no-run-if-empty gopass show -o | ydotool type --key-delay 2 --key-hold 2 -f -
