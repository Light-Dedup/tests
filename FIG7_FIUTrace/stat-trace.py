#!/usr/bin/env python3

import sys

trace = sys.argv[1]
hash_map = dict()

tot_wblks = 0
unique_wblks = 0
tot_blks = 0
with open(trace, "r") as f:
    lines = f.readlines()
    for line in lines:
        [ts, pid, process, lba, blks, rw, major, minor, md5] = line.split(" ")
        if rw == "W":
            if md5 not in hash_map:
                hash_map[md5] = 1
            else:
                hash_map[md5] += 1
            tot_wblks += 1
        tot_blks += 1

unique_wblks = len(hash_map.items())

print("Total Blocks: {}".format(tot_blks))
print("Write to Read Ratio: {}".format(tot_wblks / tot_blks))
print("Total Write Blocks: {}".format(tot_wblks))
print("Unique Write Blocks: {}".format(unique_wblks))
print("Duplicate Write Blocks: {}".format(tot_wblks - unique_wblks))
print("Duplicate ratio: {}".format((tot_wblks - unique_wblks) / tot_wblks))