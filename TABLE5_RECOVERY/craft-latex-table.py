#!/usr/bin/env python3
from traceback import print_tb
import pandas as pd
import os

with open("./avg-result-in-paper", "r") as f:
    df = pd.read_csv(f, delim_whitespace=True, engine='python')

os.system("echo > latex-table")
os.system("cat latex-table-template | tee latex-table > /dev/null")

LIGHT_DEDUP_NORMAL = df.iloc[0:3]
LIGHT_DEDUP_FAIL = df.iloc[3:6]
NOVA_NORMAL = df.iloc[6:9]
NOVA_FAIL = df.iloc[9:12]

def replace(a, b):
    cmd = "sed -i 's/{}/{}/g' latex-table > /dev/null".format(a, b)
    os.system(cmd)

targets = [("NOVA-FAIL", NOVA_FAIL), ("NOVA-NORMAL", NOVA_NORMAL), ("Light-Dedup-NORMAL", LIGHT_DEDUP_NORMAL), ("Light-Dedup-FAIL", LIGHT_DEDUP_FAIL), ("NOVA-UMOUNT", NOVA_NORMAL), ("Light-Dedup-UMOUNT", LIGHT_DEDUP_NORMAL)]

for target in targets:
    for idx, size in enumerate(["32", "64", "128"]):
        target_name = target[0]
        target_df = target[1]
        key = "{" + target_name + "-" + size + "}"
        if target_name.find("UMOUNT") != -1:
            replace(key, round(float(target_df.iloc[idx]["umount_time"]), 3))
        else:
            replace(key, round(float(target_df.iloc[idx]["recovery"]), 3))