#!/usr/bin/env python3

import csv


output_table = 'table-calculated'

F_SIZE = 64 # GiB

def table_alias(table:str):
    return "first_write" if table == "first-table-simple-random" else "second_write"

def process_table(table:str, writer):
    with open(table, 'r') as i_f:
        reader = csv.DictReader(i_f, delimiter=' ')
        content = []
        
        for row in reader:
            content.append(row)
        
        base = content[0]
        all_in_nvm = content[1]

        def calc_amount(base, row, type:str):
            return (int(row[type]) - int(base[type])) / (int(base["file_size"]) * 1024 * 256)

        writer.writerow([table_alias(table), calc_amount(base, all_in_nvm, "read"), calc_amount(base, all_in_nvm, "write")])
        
        
with open(output_table, 'w') as o_f:
    writer = csv.writer(o_f, delimiter=' ')
    writer.writerow(["number", "read", "write"])
    process_table("first-table-simple-random", writer)
    process_table("second-table-simple-random", writer)