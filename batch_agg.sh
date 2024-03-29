#!/usr/bin/env bash

loop=1
if [ "$1" ]; then
  loop=$1
fi

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

    # Aggregate Results
    if [ -f "agg.sh" ]; then
        bash agg.sh "$loop"
    fi

    cd - || exit
  fi
done

