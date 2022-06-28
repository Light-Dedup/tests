#!/usr/bin/env python3


import sys
import os
import threading
import time

granularity = 4096

backup_from = sys.argv[1]
backup_to = sys.argv[2]
tmp = sys.argv[3]
threads = int(sys.argv[4])

data_names = os.listdir(backup_from)
data_names = sorted(data_names)

def reinit_env():
    os.system("bash synexm.sh")

def tear_pack_down(path:str, num:int):
    fstat = os.stat(path)
    bytes_per_part = int(fstat.st_size / num)
    parts_path = backup_to + '/' + path.split('/')[-1]
    tmp_path = tmp + '/' + path.split('/')[-1] + "/"
    os.mkdir(tmp_path)
    os.mkdir(parts_path)
    os.system("split --bytes=" + str(bytes_per_part) + " " + path + " " + tmp_path)
    return tmp_path

def slice_and_write(path:str, granularity:int, threads:int):
    if threads == 1:
        target_path = backup_to + '/' + path.split('/')[-1]
    else:
        target_path = backup_to + '/' + path.split('/')[-2] + '/' + path.split('/')[-1]  
    os.mknod(target_path)
    with open(target_path, 'wb') as of:
        with open(path, 'rb') as f:
            while True:
                data = f.read(granularity)
                if not data:
                    break
                of.write(data)

reinit_env()

for data_name in data_names:
    data_path = os.path.join(backup_from, data_name)
    if os.path.isfile(data_path):
        fstat = os.stat(data_path)
        if threads == 1:
            start = time.time()
            slice_and_write(data_path, granularity, threads)
        else:
            parts_path = tear_pack_down(data_path, threads)
            pools = []
            start = time.time()
            for part_path in os.listdir(parts_path):
                t = threading.Thread(target=slice_and_write, args=(os.path.join(parts_path, part_path), granularity, threads))
                pools.append(t)
                t.start()
            for t in pools:
                t.join()
        end = time.time()
        print("{}: {:.3f}s, {}MiB/s".format(data_name, end - start, (fstat.st_size / (end - start)) / 1024 / 1024))    