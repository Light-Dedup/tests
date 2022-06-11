#!/usr/bin/env bash

OUTNAME="stdout"

bash ./compile.sh
 
function get_pmem0_id () {
  if ! sudo ipmctl show -performance | grep "DimmID=" | sed -n "1p" | sed 's/---//g' | sed 's/DimmID=//g'; then
    echo "Error: Cannot get pmem0 id. Did you active pmem0?"
    exit 1
  fi
}

# set default pmem id
PMEM_ID=$(get_pmem0_id)

function set_pmem_id() {
  FILE=$1
  PMEM_ID=$2
  sed_cmd=s/PMEM_ID/"$PMEM_ID"/g
  sed -i "$sed_cmd" "$FILE"
}

for filename in `ls`
do
  if test -d "$filename" ; then
    cd "$filename" || exit

    # Set pmem0 id
    if [[ "${filename}" == "FIG10_Percore_Allocator" ]]; then
      test.sh "$PMEM_ID" > $OUTNAME
    elif [[ "${filename}" == "TABLE2_Amplification" ]]; then
      test.sh "$PMEM_ID" > $OUTNAME
    elif [[ "${filename}" == "TABLE4_AgingSystem" ]]; then
      test.sh "$PMEM_ID" > $OUTNAME
    else    
      bash test.sh > $OUTNAME
    fi

    # Run Process Script
    if [ -f "process.py" ]; then
        python3 process.py
    fi
  
    cd - || exit
  fi
done
