#!/usr/bin/env python3
import pandas as pd
import os

# with open("./avg-result-calculated-in-paper", "r") as f:
with open("./table-calculated", "r") as f:
    df = pd.read_csv(f, delim_whitespace=True, engine='python')


os.system("echo > latex-table")
os.system("cat latex-table-template | tee latex-table > /dev/null")

REGION_NEW = df.iloc[0]
ENTRY_NEW = df.iloc[1]
REGION_AGE = df.iloc[2]
ENTRY_AGE = df.iloc[3]

def replace(a, b):
    cmd = "sed -i 's/{}/{}/g' latex-table > /dev/null".format(a, b)
    os.system(cmd)

targets = [("REGION-NEW", REGION_NEW), ("REGION-AGE", REGION_AGE), ("ENTRY-NEW", ENTRY_NEW), ("ENTRY-AGE", ENTRY_AGE)]

cols_alias = {
    "read_amp": "RAMP",  
    "write_amp": "WAMP",
    "throughput(MiB/s)": "BW",
    "latency(ns)": "LAT"
}

for target in targets:
    for col in ["read_amp", "write_amp", "throughput(MiB/s)", "latency(ns)"]:
        target_name = target[0]
        target_df = target[1]
        key = "{" + target_name + "-" + cols_alias[col] + "}"
        replace(key, round(float(target_df[col]), 2))

        if col == "read_amp":
            key = "{" + target_name + "-" + "RPB" + "}"
            replace(key, round(float(target_df[col]) * 32, 2))
        elif col == "write_amp":
            key = "{" + target_name + "-" + "WPB" + "}"
            replace(key, round(float(target_df[col]) * 32, 2))