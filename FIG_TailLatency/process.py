#!/usr/bin/env python3

import collections
import csv


output_table = 'table-calculated'

def process_table(table:str, writer):
    with open(table, 'r') as i_f:
        reader = csv.DictReader(i_f, delimiter=' ')
        content = []
        
        for row in reader:
            content.append(row)
        
        Light_Dedup = content[0]
        Light_Dedup_SHA256 = content[1]
        NV_Dedup = content[2]
        NOVA = content[3]

        def calc_diff(base: collections.OrderedDict, row: collections.OrderedDict, col: int):
            return (int(list(row.values())[col]) - int(list(base.values())[col]))
        
        def write_diff_latency(writer, name, base, row):
            tail_latency = []
            for col in range(3, 14):
                tail_latency.append(calc_diff(row, base, col))
            _row = [name, "0", "1"]
            _row.extend(tail_latency)
            writer.writerow(_row)

        write_diff_latency(writer, "Light-Dedup", Light_Dedup, NOVA)
        write_diff_latency(writer, "Light-Dedup(SHA256)", Light_Dedup_SHA256, NOVA)
        write_diff_latency(writer, "NV-Dedup", NV_Dedup, NOVA)
        
with open(output_table, 'w') as o_f:
    writer = csv.writer(o_f, delimiter=' ')
    writer.writerow(["file_system",  "dup_rate", "num_job", "90", "95", "99", "99.5", "99.9", "99.95", "99.99", "99.999","99.9999", "99.99999", "99.999999"])
    process_table("performance-comparison-table", writer)