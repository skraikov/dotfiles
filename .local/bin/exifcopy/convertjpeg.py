import sys
import os.path
import shutil
import glob
import re
import subprocess
import pyexiv2

TEMP_DIR = os.environ['XDG_RUNTIME_DIR']
FILES = glob.glob("./**/*", recursive=True)

total_size_before = 0
total_size_after = 0

# select supported files only
SUPPORTED_FILES = []
for file in FILES:
    if not os.path.isfile(file):
        continue

    # check this is JPG image
    m = re.match(r".*\.jpe?g", file, re.I)
    if not m:
        continue

    SUPPORTED_FILES.append(file)

SUPPORTED_FILES.sort()

total_count = len(SUPPORTED_FILES)
current_count = 0

# process files
for file in SUPPORTED_FILES:
    current_count = current_count + 1

    ctime = os.path.getctime(file)

    size_before = os.path.getsize(file)
    total_size_before += size_before

    print(str(current_count) + '/' + str(total_count) + ': ' + file + ': ' + str(size_before), end='', flush=True)

    # try by default
    file_basename = os.path.basename(file)
    output_file = os.path.join(TEMP_DIR, file_basename)

    # compress by guetzli
    try:
        input_file = file
        print(' -> guetzli', end='', flush=True)
        #shutil.copy(input_file, output_file)
        r = subprocess.run(['guetzli', input_file, output_file], check=False, stderr=subprocess.PIPE)
        if r.returncode != 0:
            raise Exception('guetzli fails!')
    except:
        # guetzli fails, try to convert input file to PNG
        print(' FAIL!', end='', flush=True)
        # convert to png
        file_base, file_ext = os.path.splitext(file_basename)
        png_file = os.path.join(TEMP_DIR, file_base + '.png')
        print(' -> png', end='', flush=True)
        subprocess.run(['convert', file, png_file])
        # run guetzli on png
        print(' -> guetzli', end='', flush=True)
        subprocess.run(['guetzli', png_file, output_file])
        os.remove(png_file)

    # copy metadata
    metadata_src = pyexiv2.ImageMetadata(file)
    metadata_src.read()

    metadata_dst = pyexiv2.ImageMetadata(output_file)
    metadata_dst.read()
    metadata_dst.previews.clear()

    metadata_src.copy(metadata_dst)

    metadata_dst.write()

    # if size after guetzli is not smaller, revert original file
    size_after_guetzli = os.path.getsize(output_file)
    if size_before <= size_after_guetzli:
        print(' -> ' + str(size_after_guetzli) + ' -> restore', end='', flush=True)
        shutil.copy(file, output_file)

    # delete thumbnails
    print(' -> exiv2', end='', flush=True)
    res = subprocess.run(['exiv2','-dt',output_file])
    if res.returncode != 0:
        raise Exception('exiv2 fails!')

    size_after = os.path.getsize(output_file)
    total_size_after += size_after
    print(' -> ' + str(size_after) + ' ( ' + str(size_after - size_before) + ', total ' + str(total_size_after - total_size_before) +')')

    # replace source file
    shutil.move(output_file, file)

print('')
print('Totals: ' + str(total_size_before) + ' -> ' + str(total_size_after) + ', reduce:' + str(total_size_before - total_size_after))