#!/bin/bash

gopass ls --flat | rofi -dmenu | xargs --no-run-if-empty gopass otp -o | ydotool type --key-delay 100 -f -
