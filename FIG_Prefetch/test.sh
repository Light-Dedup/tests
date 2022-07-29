#!/usr/bin/env bash

loop=1
if [ "$1" ]; then
    loop=$1
fi

./test-single.sh "$loop"
./test-multi.sh "$loop"