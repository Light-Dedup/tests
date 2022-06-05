#!/usr/bin/env bash

OUTNAME="stdout"

for filename in `ls`
do
  if test -d $filename ; then
    cd $filename || exit
    if [[ "${filename}" == "FIG8_IOR" ]]; then
        bash test-IOR.sh > $OUTNAME
    elif [[ "${filename}" == "FIG9_BeffIO" ]]; then
        bash test-BEFFIO.sh > $OUTNAME
    elif [[ "${filename}" == "TABLE2_Amplification" ]]; then
        bash test-simple-random.sh > $OUTNAME
    else
        bash test.sh > $OUTNAME
    fi
    cd - || exit
 fi
done
