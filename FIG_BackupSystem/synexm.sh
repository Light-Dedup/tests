#!/usr/bin/env bash

bash "clear.sh"

for i in {0..20}; do
    ver=$(printf "%03d\n" "$i")
    # Create
    touch "./exmdata/SYN/SYN$ver"
    touch "./exmdata/WEB/WEB$ver"
    # Inflate
    dd if=/dev/urandom of="./exmdata/SYN/SYN$ver" bs=1M count=1 status=none
    dd if=/dev/urandom of="./exmdata/WEB/WEB$ver" bs=1M count=1 status=none
done
