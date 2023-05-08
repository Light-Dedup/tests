#!/usr/bin/env python3
import pandas as pd
import os

# with open("./avg-test-result-in-paper", "r") as f:
with open("./breakdown-table", "r") as f:
    df = pd.read_csv(f, delim_whitespace=True, engine='python')

os.system("echo > latex-table")
os.system("cat latex-table-template | tee latex-table > /dev/null")

NOVA = df.iloc[0]
NAIVE_1 = df.iloc[1]
NAIVE_2 = df.iloc[2]

def replace(a, b):
    cmd = "sed -i 's/{}/{}/g' latex-table > /dev/null".format(a, b)
    os.system(cmd)

targets = [("NOVA", NOVA), ("NAIVE-1", NAIVE_1), ("NAIVE-2", NAIVE_2)]
cols_alias = {
    "fp_time": "FP",  
    "IO_time": "WRITE",
    "cmp_time": "CMP",
    "others": "OTHERS",
    "bw": "BW"
}

for target in targets:
    for col in ["fp_time", "IO_time", "cmp_time", "others", "bw"]:
        target_name = target[0]
        target_df = target[1]
        key = "{" + target_name + "-" + cols_alias[col] + "}"
        replace(key, target_df[col])