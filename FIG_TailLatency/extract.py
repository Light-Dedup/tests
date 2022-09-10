import os, sys

fio_output = sys.argv[1]
tail_latency = sys.argv[2] # 99.90, 99.95

ret = os.popen("cat {} | grep 'th=\['".format(fio_output)).read()
lines = ret.splitlines()
for line in lines:
    line = line.replace("|", "")
    line = line.replace(" ", "")
    line = line.strip()
    tail_latency_pairs = line.split(",")
    for tail_latency_pair in tail_latency_pairs:
        if tail_latency_pair.find(tail_latency) != -1:
            left_index = tail_latency_pair.find("[")
            right_index = tail_latency_pair.find("]")
            tail_latency_value = tail_latency_pair[left_index + 1 : right_index]
            print(tail_latency_value)
            exit(0)