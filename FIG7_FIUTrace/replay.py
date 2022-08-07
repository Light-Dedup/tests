#!/usr/bin/env python3

import sys
import os

trace_pattern = sys.argv[1]
trace_start = int(sys.argv[2])
trace_end = int(sys.argv[3])

cur_dir = os.path.split(os.path.realpath(__file__))[0]
nvm_tools_dir = os.path.join(cur_dir, "..", "..", "nvm_tools")
replay_time = 0
size = 0

for i in range(trace_start, trace_end + 1):
    trace = trace_pattern.replace("$n", str(i))
    print("Processing trace: " + trace)
    ret = os.popen("{}/replay -f {} -d /mnt/pmem0/test".format(nvm_tools_dir, trace)).read()    
    replay_time += float(ret.split(": ")[1].split(" ")[0])
    size += int(ret.split(": ")[2].split(" ")[0])

print("Replay Time: {} ms".format(replay_time))
print("Replay Size: {} MiB".format(size))
print("Replay Bandwidth: {} MiB/s".format(size / (replay_time / 1000)))