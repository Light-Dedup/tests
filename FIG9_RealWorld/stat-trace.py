#!/usr/bin/env python3

import sys
import time
import matplotlib
import matplotlib.pyplot as plt
from matplotlib import style

trace_path = sys.argv[1]
trace_type = sys.argv[2]

content_map = dict()
ofs_map = dict()
consecutive_map = dict()

tot_wblks = 0
unique_wblks = 0
tot_blks = 0

def add_item_to_map(_map, key, value):
    if key in _map:
        _map[key] += value
    else:
        _map[key] = value

def append_item_to_map(_map, key, value):
    if key not in _map:
        _map[key] = []
    _map[key].append(value)

consecutive_blks = 1
consecutive_start_lba = 0

trace = trace_path
print("Processing trace: " + trace)
last_lba = -9
with open(trace, "r") as f:
    lines = f.readlines()
    consecutive_blks = 1
    for line in lines:
        line = line.strip()
        if trace_type == "fiu":
            try:
                [ts, pid, process, lba, blks, rw, major, minor, md5] = line.split(" ")
                if rw == "W":
                    add_item_to_map(content_map, md5, 1)
                    tot_wblks += 1
                tot_blks += 1
                # insert as string
                add_item_to_map(ofs_map, lba, 1)
                lba = int(lba)
                if lba - last_lba == 8:
                    consecutive_blks += 1
                else:
                    append_item_to_map(consecutive_map, consecutive_blks, (consecutive_start_lba, consecutive_start_lba + (consecutive_blks - 1) * 8))
                    consecutive_blks = 1
                    consecutive_start_lba = lba
                last_lba = lba
            except:
                continue
        elif trace_type == "hitsz":
            try:
                [ts, fid, lba, md5] = line.split(" ")
                add_item_to_map(content_map, md5, 1)
                tot_wblks += 1
                tot_blks += 1
                # insert as string
                add_item_to_map(ofs_map, lba, 1)
                lba = int(lba)
                if lba - last_lba == 8:
                    consecutive_blks += 1
                else:
                    append_item_to_map(consecutive_map, consecutive_blks, (consecutive_start_lba, consecutive_start_lba + (consecutive_blks - 1) * 8))
                    consecutive_blks = 1
                    consecutive_start_lba = lba
                last_lba = lba
            except:
                continue

unique_wblks = len(content_map.items())

print("Total Blocks: {}".format(tot_blks))
print("Total Size: {} GB".format(tot_blks * 4096 / 1024 / 1024 / 1024))
print("Write to Read Ratio: {}".format(tot_wblks / tot_blks))
print("Total Write Blocks: {}".format(tot_wblks))
print("Unique Write Blocks: {}".format(unique_wblks))
print("Duplicate Write Blocks: {}".format(tot_wblks - unique_wblks))
print("Duplicate (write) ratio: {}".format((tot_wblks - unique_wblks) / tot_wblks))

cnt = sorted(consecutive_map.items())
lens = []
len_cnt = []
for item in cnt:
    lens.append(item[0])
    len_cnt.append(item[0] * item[1])
len_cnt_sum = [len_cnt[0]]
for i in range(1, len(len_cnt)):
    len_cnt_sum.append(len_cnt_sum[i - 1] + len_cnt[i])

# print(cnt)
plt.plot(lens, len_cnt_sum)
plt.xscale('log', base=10)
plt.title('Continuousness')
plt.xlabel('Length')
plt.ylabel('Accumulated record number')
plt.savefig("stat_fiu.png")
plt.close()