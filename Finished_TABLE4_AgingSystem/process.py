#!/usr/bin/env python3

import csv


output_table = 'table-calculated'

def table_alias(table:str):
    return "FreshSystem" if table == "newly_table" else "AgedSystem"

def process_table(table:str, writer):
    with open(table, 'r') as i_f:
        reader = csv.DictReader(i_f, delimiter=' ')
        content = []
        
        for row in reader:
            content.append(row)
        
        base = content[0]
        region = content[1]
        entry = content[2]

        def calc_amp(table, base, row, type:str):
            if table == "newly_table":
                file_size = 128
            elif table == "aging_table":
                file_size = 64
            return (int(row[type]) - int(base[type])) / (file_size * 1024 * 256) / 32
        
        def calc_bw(table, row):
            if table == "newly_table":
                file_size = 128
            elif table == "aging_table":
                file_size = 64
            return (file_size * 1024) / (float(row['time']) / 1000)
        
        def calc_lat(table, row):
            if table == "newly_table":
                file_size = 128
            elif table == "aging_table":
                file_size = 64
            return (float(row['time']) * 1000 * 1000) / (file_size * 1024 * 256) 

        writer.writerow([table_alias(table), "Region", calc_amp(table, base, region, "read"), calc_amp(table, base, region, "write"), calc_bw(table, region), calc_lat(table, region)])

        writer.writerow([table_alias(table), "Entry", calc_amp(table, base, entry, "read"), calc_amp(table, base, entry, "write"), calc_bw(table, entry), calc_lat(table, entry)])
        
with open(output_table, 'w') as o_f:
    writer = csv.writer(o_f, delimiter=' ')
    writer.writerow(["system", "metadata_layout", "read_amp", "write_amp", "throughput(MiB/s)", "latency(ns)"])
    process_table("newly_table", writer)
    process_table("aging_table", writer)