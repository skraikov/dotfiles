#!/bin/bash

gopass ls --flat | fuzzel --dmenu | xargs --no-run-if-empty gopass otp -o | ydotool type --key-delay 100 -f -
