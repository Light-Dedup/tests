#!/usr/bash

loop=1
if [ "$1" ]; then
    loop=$1
fi

table_name="performance-comparison-table"

python3 ../aggregate.py "$table_name" "$loop"
mv "$table_name" "$table_name"-orig
mv "$table_name"_agg "$table_name"