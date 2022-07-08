#!/usr/bin/env bash

mkdir -p fig-fetched

for filename in `ls`
do
  if test -d "$filename" ; then
    cd "$filename" || exit 
    for subfilename in `ls`
    do
        if ( echo "$subfilename" | grep -q "FIG" ); then 
            cp -f "$subfilename" ../fig-fetched/ > /dev/null 2>&1
        fi
    done
    cd - > /dev/null || exit
  fi
done
