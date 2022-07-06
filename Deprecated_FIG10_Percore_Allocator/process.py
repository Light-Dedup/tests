#!/usr/bin/env python3

import csv


grp_num = 3
target_table = 'table'
target_rows = [ "file_system", "file_size", "num_job", "read", "write", "t"]
output_table = 'table-calculated'
output_rows = [ "allocators",	"read_amp",	"write_amp", "dedup_cost" ]

with open(target_table, 'r') as i_f:
    reader = csv.DictReader(i_f, delimiter=' ')
    content = []
    inner = []
    
    for row in reader:
        if len(inner) == grp_num:
            content.append(inner)
            inner = []
        inner.append(row)
    
    if len(inner) == grp_num:
        content.append(inner)

    with open(output_table, 'w') as o_f:
        writer = csv.writer(o_f, delimiter=' ')
        
        def calc_amp(base, row, type:str):
            return (int(row[type]) - int(base[type])) / (int(base["file_size"]) * 1024 * 256) / 32
        def calc_cost(base, row):
            return (int(row['t']) - int(base['t'])) / int(row['t'])
        
        writer.writerow(output_rows)
        
        # for single
        for grp in content:
            base = grp[0]
            single = grp[1]
            calculated_row = [single["file_system"], calc_amp(base, single, "read"), calc_amp(base, single, "write"), calc_cost(base, single)]
            writer.writerow(calculated_row)

        # for percpu
        for grp in content:
            base = grp[0]
            percpu = grp[2]
            calculated_row = [percpu["file_system"], calc_amp(base, percpu, "read"), calc_amp(base, percpu, "write"), calc_cost(base, percpu)]
            writer.writerow(calculated_row)

