import glob
import sys

from PIL import Image

# check sys argument
if len(sys.argv) == 1:
    print('Usage: python gif_maker.py <file_name: files are of form file_name_*.png>')
    exit(1)

# filepaths
fp_in = '{}_*.png'.format(sys.argv[1])
fp_out = '{}.gif'.format(sys.argv[1])

# https://pillow.readthedocs.io/en/stable/handbook/image-file-formats.html#gif
img, *imgs = [Image.open(f) for f in sorted(glob.glob(fp_in))]
img.save(fp=fp_out, format='GIF', append_images=imgs,
         save_all=True, duration=500, loop=0)
