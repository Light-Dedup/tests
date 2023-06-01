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

    if [ -f "craft-latex-table.py" ]; then
        python3 craft-latex-table.py
    fi

    cd - || exit
  fi
done
