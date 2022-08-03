#!/usr/bash

loop=1
if [ "$1" ]; then
    loop=$1
fi

table_name="performance-comparison-table"

sed 's/0m//g' -i "$table_name"
sed 's/s//g' -i "$table_name"
sed 's/file_ytem/file_system/g' -i "$table_name"
sed 's/file_ize/file_size/g' -i "$table_name"
 
python3 ../aggregate.py "$table_name" "$loop"
mv "$table_name" "$table_name"-orig
mv "$table_name"_agg "$table_name"
