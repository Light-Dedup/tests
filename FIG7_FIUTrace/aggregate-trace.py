#!/usr/bin/env python3
from posixpath import basename
import sys
import os

trace_pattern = sys.argv[1]
trace_start = int(sys.argv[2])
trace_end = int(sys.argv[3])

trace_file_path = ""
if len(sys.argv) > 4:
    trace_file_path = sys.argv[4]

cur_dir = os.path.split(os.path.realpath(__file__))[0]
nvm_tools_dir = cur_dir
trace_dir = os.path.dirname(trace_pattern)

if trace_file_path == "":
    trace_file_path = os.path.join(trace_dir, basename(trace_pattern.replace("$n", str(trace_start) + "-" + str(trace_end))))

print("Aggregating trace file to {}...".format(trace_file_path))

with open(trace_file_path, "w+") as trace_file:
    for i in range(trace_start, trace_end + 1):
        cur_trace = trace_pattern.replace("$n", str(i))
        print("Aggregating {} to {}".format(cur_trace, trace_file_path))
        with open(cur_trace, "r") as f:
            lines = f.readlines()
            for line in lines:
                try:
                    [ts, pid, process, lba, blks, rw, major, minor, md5] = line.split(" ")
                    trace_file.write(line)
                except:
                    continue
        # os.remove(trace)

print("Done!")