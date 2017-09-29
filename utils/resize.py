#!/usr/bin/env python

from PIL import Image
import sys, os

def usage():
    print('Usage: %s size [files...]' % sys.argv[0])
    exit()

try:
    size = int(sys.argv[1])
    images = sys.argv[2:]
except Exception:
    usage()

if len(images) <= 0:
    usage()

size = (size, size)
for imageFileName in images:
    image = Image.open(imageFileName)
    filename, ext = os.path.splitext(imageFileName)
    image.thumbnail(size, Image.BICUBIC)
    image.save(filename + '-%d' % size[0] + ext, ext.replace('.', ''))