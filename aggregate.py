#!/usr/bin/env python3

import csv
import sys

table_name = sys.argv[1]
grp = int(sys.argv[2])

def is_number(s):
    try:  
        float(s)
        return True
    except ValueError:  
        pass  
    try:
        import unicodedata 
        unicodedata.numeric(s) 
        return True
    except (TypeError, ValueError):
        pass
    return False

def agg_table(table:str, grp:int):
    content = []
    with open(table, 'r') as i_f:
        cols = i_f.readline().strip().split(" ")
        rows = 0
        i_f.seek(0)
        
        reader = csv.DictReader(i_f, delimiter=' ')    

        for row in reader:
            rows += 1
            content.append(row)

        rows_per_grp = rows // grp
        
        for row in range(rows):
            line = content[row]
            if row >= rows_per_grp:
                for col in cols:
                    if is_number(line[col]):
                        if str.isdigit(str(line[col])):
                            content[row % rows_per_grp][col] = int(content[row % rows_per_grp][col])
                            content[row % rows_per_grp][col] += int(line[col])
                        else:
                            content[row % rows_per_grp][col] = float(content[row % rows_per_grp][col])
                            content[row % rows_per_grp][col] += float(line[col])
        
        for row in range(rows_per_grp):
            for col in cols:
                if is_number(content[row][col]):
                    if str.isdigit(str(content[row][col])):
                        content[row][col] = int(content[row][col])
                        content[row][col] = content[row][col] // grp
                    else:
                        content[row][col] = float(content[row][col])
                        content[row][col] /= grp

    with open(table + "_agg", 'w') as o_f:
        writer = csv.writer(o_f, delimiter=' ')
        writer.writerow(cols)
        for row in range(rows_per_grp):
            line = []
            for col in cols:
                line.append(content[row][col])
            writer.writerow(line)

agg_table(table_name, grp)