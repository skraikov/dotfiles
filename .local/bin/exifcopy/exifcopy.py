import sys
import os.path
import shutil
import glob
import pyexiv2
import datetime

LIB_DIR = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1 else "~/Sync/Photo")
FILES = glob.glob("./**/*", recursive=True)

for file in FILES:
    if not os.path.isfile(file):
        continue
    metadata = pyexiv2.ImageMetadata(file)
    metadata.read()
    d = None
    if 'Exif.Image.DateTime' in set(metadata.exif_keys):
        d = metadata['Exif.Image.DateTime']
    elif 'Iptc.Application2.DateCreated' in set(metadata.iptc_keys):
        d = metadata['Iptc.Application2.DateCreated']
    elif 'Xmp.xmp.ModifyDate' in set(metadata.xmp_keys):
        d = metadata['Xmp.xmp.ModifyDate']

    if d != None and isinstance(d.value, datetime.datetime):
        date_dir = d.value.strftime("%Y-%m-%d")
        month_dir = d.value.strftime("%Y-%m")
        year_dir = d.value.strftime("%Y")
        path = os.path.join(LIB_DIR, year_dir, month_dir, date_dir)
        try:
            file_basename = os.path.basename(file)
            print(file + ' -> ' + date_dir + '/')
            os.makedirs(path, exist_ok=True)
            new_name = os.path.join(path, file_basename)
            if os.path.exists(new_name):
                raise Exception('File already exists!')
            shutil.move(file, new_name)
            os.chmod(new_name, 0o640)
        except Exception as err:
            print(err)
    else:
        print(file + ' UNKNOWN')
