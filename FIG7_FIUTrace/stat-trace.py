#!/usr/bin/env python3

import sys
import matplotlib
import matplotlib.pyplot as plt
from matplotlib import style
trace_pattern = sys.argv[1]
trace_start = int(sys.argv[2])
trace_end = int(sys.argv[3])

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

for i in range(trace_start, trace_end + 1):
    trace = trace_pattern.replace("$n", str(i))
    print("Processing trace: " + trace)
    last_lba = -9
    with open(trace, "r") as f:
        lines = f.readlines()
        consecutive_blks = 1
        for line in lines:
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
            

unique_wblks = len(content_map.items())

print("Total Blocks: {}".format(tot_blks))
print("Total Size: {} GB".format(tot_blks * 4096 / 1024 / 1024 / 1024))
print("Write to Read Ratio: {}".format(tot_wblks / tot_blks))
print("Total Write Blocks: {}".format(tot_wblks))
print("Unique Write Blocks: {}".format(unique_wblks))
print("Duplicate Write Blocks: {}".format(tot_wblks - unique_wblks))
print("Duplicate (write) ratio: {}".format((tot_wblks - unique_wblks) / tot_wblks))


""" Plotting """
STANDARD_WIDTH = 17.8
SINGLE_COL_WIDTH = STANDARD_WIDTH / 2
DOUBLE_COL_WIDTH = STANDARD_WIDTH
def cm_to_inch(value):
    return value/2.54
    
matplotlib.rcParams['text.usetex'] = False
style.use('seaborn-white')
plt.rcParams["axes.grid"] = True
plt.rcParams["axes.grid.axis"] = "y"
plt.rcParams["grid.linewidth"] = 0.8
plt.rcParams["font.family"] = "Nimbus Roman"

fig = plt.figure(figsize = (cm_to_inch(DOUBLE_COL_WIDTH), cm_to_inch(12)))
subfig = plt.subplot(311)
# sort as integer
ofs_x = sorted(ofs_map, key=lambda x: int(x))
ofs_y = []
for ofs in ofs_x:
    ofs_y.append(ofs_map[ofs])
plt.bar(ofs_x, ofs_y)
plt.xticks(range(1, len(ofs_x), len(ofs_x) // 2 - 1))
plt.xlabel("Data access distribution")
plt.yticks(range(0, max(ofs_y) + 1, max(ofs_y) // 5))
plt.ylabel("Blocks (#.)")

subfig = plt.subplot(312)
# sort as integer
ofs_y = []
acc = 0
for idx, ofs in enumerate(ofs_x):
    ofs_y.append(acc + ofs_map[ofs])
    acc += ofs_map[ofs]
plt.plot(ofs_x, ofs_y)
plt.xticks(range(1, len(ofs_x), len(ofs_x) // 2 - 1))
plt.xlabel("Data access accumulation")
plt.yticks(range(0, max(ofs_y) + 1, max(ofs_y) // 5))
plt.ylabel("Blocks (#.)")

# subfig = plt.subplot(313)
# consecutive_x = sorted(consecutive_map)
# consecutive_y = []
# for consecutive in consecutive_x:
#     consecutive_y.append(len(consecutive_map[consecutive]))
# plt.bar(consecutive_x, consecutive_y)
# # plt.xticks(range(1, len(consecutive_x), len(consecutive_x) // 2 - 1))
# plt.xlabel("Consecutive Blocks (#.)")
# plt.yticks(range(0, max(consecutive_y) + 1, max(consecutive_y) // 5))
# plt.ylabel("Statistics (#.)")
subfig = plt.subplot(313)
consecutive_x = sorted(consecutive_map)
consecutive_y = []
acc = 0
for consecutive in consecutive_x:
    consecutive_y.append(acc + len(consecutive_map[consecutive]))
    acc += len(consecutive_map[consecutive])
plt.bar(consecutive_x, consecutive_y)
# plt.xticks(range(1, len(consecutive_x), len(consecutive_x) // 2 - 1))
plt.xlabel("Consecutive Blocks (#.)")
plt.yticks(range(0, max(consecutive_y) + 1, max(consecutive_y) // 5))
plt.ylabel("Statistics (#.)")

plt.tight_layout()
fig.savefig("map.pdf", bbox_inches = "tight")