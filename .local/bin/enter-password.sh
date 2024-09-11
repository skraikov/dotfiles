#!/bin/bash

# where to find xdotool keykodes: https://gitlab.com/nokun/gestures/-/wikis/xdotool-list-of-key-codes

gopass ls --flat | rofi -dmenu | xargs --no-run-if-empty gopass show -o | \
    sed 's/\(.\)/\1 /g' | \
    sed 's/\([A-Z]\)/shift+\1/g' | \
    sed 's/!/shift+1/g' | \
    sed 's/[$]/shift+4/g' | \
    sed 's/[#]/shift+3/g' | \
    sed 's/[-]/minus/g' | \
    sed 's/[_]/underscore/g' | \
    sed 's/  / space/g' | \
    sed 's/[%]/percent/g' | \
    sed 's/[<]/less/g' | \
    sed 's/[>]/greater/g' | \
    sed 's/[.]/period/g' | \
    sed 's/[[]/bracketleft/g' | \
    sed 's/[]]/bracketright/g' | \
    sed 's/[{]/braceleft/g' | \
    sed 's/[}]/braceright/g' | \
    sed 's/[(]/parenleft/g' | \
    sed 's/[)]/parenright/g' | \
    sed 's/[&]/ampersand/g' | \
    xargs --no-run-if-empty xdotool key
