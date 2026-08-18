#!/bin/env python

import string
import sys
import os.path
import shutil
import glob
import piexif
import datetime

LIB_DIR = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1 else "~/Sync/Photo")
FILES = glob.glob("./**/*", recursive=True)

for file in FILES:
    if not os.path.isfile(file):
        continue
    try:
        file_basename = os.path.basename(file)
        print(file, end =  ": ")
        exif_dict = piexif.load(file)
        exif0 = exif_dict.pop("0th")
        exif = exif_dict.pop("Exif")
        exifGps = exif_dict.pop("GPS")
        if exif0 is not None and piexif.ImageIFD.DateTime in exif0:
            d = exif0[piexif.ImageIFD.DateTime]
        elif exif is not None and piexif.ExifIFD.DateTimeOriginal in exif:
            d = exif[piexif.ExifIFD.DateTimeOriginal]
        elif exifGps is not None and piexif.GPSIFD.GPSDateStamp in exifGps:
            d = exifGps[piexif.GPSIFD.GPSDateStamp]
        else:
            d = None

        if isinstance(d, bytes):
            d = d.decode("utf-8")

        if isinstance(d, str):
            d = datetime.datetime.strptime(d, "%Y:%m:%d %H:%M:%S")

        if d is not None and isinstance(d, datetime.datetime):
            date_dir = d.strftime("%Y-%m-%d")
            month_dir = d.strftime("%Y-%m")
            year_dir = d.strftime("%Y")
            path = os.path.join(LIB_DIR, year_dir, month_dir, date_dir)
            print(' -> ' + date_dir + '/')
            os.makedirs(path, exist_ok=True)
            new_name = os.path.join(path, file_basename)
            if os.path.exists(new_name):
                raise Exception('File already exists!')
            shutil.move(file, new_name)
            os.chmod(new_name, 0o640)
        else:
            print('UNKNOWN')
    except Exception as err:
        print(err)
