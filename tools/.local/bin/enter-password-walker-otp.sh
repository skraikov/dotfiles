#!/bin/bash

gopass ls --flat | walker --dmenu -H | xargs --no-run-if-empty gopass otp -o | ydotool type --key-delay 100 -f -
