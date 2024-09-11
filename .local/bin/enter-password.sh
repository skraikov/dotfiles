#!/bin/bash

gopass ls --flat | rofi -dmenu | xargs --no-run-if-empty gopass show -o | \
    sed 's/\(.\)/\1 /g' | sed 's/\([A-Z]\)/shift+\1/g' | sed 's/!/shift+1/g' | \
    sed 's/[(]/shift+9/g' | sed 's/[$]/shift+4/g' | sed 's/[#]/shift+3/g' | \
    sed 's/[-]/minus/g' | \
    xargs --no-run-if-empty xdotool key
