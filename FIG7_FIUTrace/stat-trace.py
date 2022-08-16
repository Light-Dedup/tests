#!/usr/bin/env python3

import sys


trace_pattern = sys.argv[1]
trace_start = int(sys.argv[2])
trace_end = int(sys.argv[3])

hash_map = dict()

tot_wblks = 0
unique_wblks = 0
tot_blks = 0
ofs_start = 1000000000000000000000000000000000
ofs_end = 0

for i in range(trace_start, trace_end + 1):
    trace = trace_pattern.replace("$n", str(i))
    print("Processing trace: " + trace)
    with open(trace, "r") as f:
        lines = f.readlines()
        for line in lines:
            try:
                [ts, pid, process, lba, blks, rw, major, minor, md5] = line.split(" ")
                if int(lba) * 512 > ofs_end:
                    ofs_end = int(lba) * 512
                if int(lba) * 512 < ofs_start:
                    ofs_start = int(lba) * 512
                if rw == "W":
                    if md5 not in hash_map:
                        hash_map[md5] = 1
                    else:
                        hash_map[md5] += 1
                    tot_wblks += 1
                tot_blks += 1
            except:
                continue
            

unique_wblks = len(hash_map.items())

print("Total Blocks: {}".format(tot_blks))
print("Total Size: {} GB".format(tot_blks * 4096 / 1024 / 1024 / 1024))
print("Write to Read Ratio: {}".format(tot_wblks / tot_blks))
print("Total Write Blocks: {}".format(tot_wblks))
print("Unique Write Blocks: {}".format(unique_wblks))
print("Duplicate Write Blocks: {}".format(tot_wblks - unique_wblks))
print("Duplicate ratio: {}".format((tot_wblks - unique_wblks) / tot_wblks))
print("Start LBA ofs: {}".format(ofs_start))
print("End LBA ofs: {}".format(ofs_end))
print("WSS: {} GB".format((ofs_end - ofs_start) / 1024 / 1024 / 1024))