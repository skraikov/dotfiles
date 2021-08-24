#!/bin/sh

script_dir="$(dirname "$0")/exifcopy"

source "$script_dir/venv/bin/activate"
python "$script_dir/convertjpeg.py" $@