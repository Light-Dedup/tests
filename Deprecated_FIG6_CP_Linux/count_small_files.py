#!/usr/bin/env python3

import sys
import os

all_files = 0
small_files = 0

def traverse_and_statics(dirname):
    dirs = os.listdir(dirname)
    for i in range(0, len(dirs)):
        path = os.path.join(dirname, dirs[i])
        if os.path.isdir(path):
            traverse_and_statics(path)
        elif os.path.isfile(path):
            global all_files
            global small_files
            all_files += 1
            stat = os.stat(path)
            if stat.st_size < 4096:
                small_files += 1


traverse_and_statics(sys.argv[1])

print("small files: " + str(small_files))
print("all   files: " + str(all_files))
print("percentage: " + str((small_files * 100) / all_files))