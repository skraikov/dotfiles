#!/bin/bash

cd /home/serge/Projects/\!vagrant
find . -name Vagrantfile | cut -c 3- | rev | cut -c 13- | rev | rofi -dmenu | xargs -I dir --no-run-if-empty sh -c 'cd dir && vagrant up'
