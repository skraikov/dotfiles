#!/bin/bash

gopass ls --flat | rofi -dmenu | xargs --no-run-if-empty gopass otp -o | sed 's/\(.\)/\1 /g' | sed 's/\([A-Z]\)/shift+\1/g' | sed 's/!/shift+1/g' | xargs --no-run-if-empty xdotool key --delay 100