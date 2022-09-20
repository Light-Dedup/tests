#!/usr/bin/bash
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

    if [ -f "plot.ipynb" ]; then
        ipython plot.ipynb
    fi

    if [ -f "report.ipynb" ]; then
        ipython report.ipynb
    fi

    cd - || exit
  fi
done
