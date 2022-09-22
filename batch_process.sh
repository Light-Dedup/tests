#!/usr/bin/env bash


for filename in `ls`
do
  if test -d "$filename" ; then

    if ( echo "$filename" | grep -q "Deprecated" ); then 
      continue
    fi

    if ( echo "$filename" | grep -q "Finished" ); then 
      continue
    fi

    if ( echo "$filename" | grep -q "TODO" ); then 
      continue
    fi

    cd "$filename" || exit

    # Run Process Script
    if [ -f "process.py" ]; then
        python3 process.py
    fi

    cd - || exit
  fi
done

