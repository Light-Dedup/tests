#!/usr/bin/env python3
import pandas as pd
import os

with open("./table-calculated", "r") as f:
    df = pd.read_csv(f, delim_whitespace=True, engine='python')

os.system("echo > latex-table")
os.system("cat latex-table-template | tee latex-table > /dev/null")

FIRST = df.iloc[0]
SECOND = df.iloc[1]

def replace(a, b):
    cmd = "sed -i 's/{}/{}/g' latex-table > /dev/null".format(a, b)
    os.system(cmd)

targets = [("FIRST", FIRST), ("SECOND", SECOND)]
cols_alias = {
    "read": "READ",  
    "write": "WRITE"
}

for target in targets:
    for col in ["read", "write"]:
        target_name = target[0]
        target_df = target[1]
        key = "{" + target_name + "-" + cols_alias[col] + "}"
        replace(key, round(float(target_df[col]), 2))