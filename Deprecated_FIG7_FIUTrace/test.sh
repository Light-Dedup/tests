#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA

FILE_SYSTEMS=( "Light-Dedup" "Light-Dedup(SHA256)" "NV-Dedup" "NOVA")
SETUPS=( "setup_nova.sh" "setup_nova.sh" "setup_nvdedup.sh" "setup_nova.sh" )
BRANCHES=( "master" "sha256" "master" "original" )
TRACES=( "homes-110108-112108.1-21.blkparse" "webmail+online.cs.fiu.edu-110108-113008.1-21.blkparse" "cheetah.cs.fiu.edu-110108-113008.1-2.blkparse" )
MAX_C_BLKS=( 1 512 )
NUM_JOBS=( 1 2 4 8 16 )

TABLE_NAME="$ABS_PATH/performance-comparison-table"
table_create "$TABLE_NAME" "file_system trace cblks job bandwidth(MiB/s)"

loop=1
if [ "$1" ]; then
    loop=$1
fi

for ((i=1; i <= loop; i++))
do
    for cblks in "${MAX_C_BLKS[@]}"; do
        STEP=0
        for file_system in "${FILE_SYSTEMS[@]}"; do
            for TRACE in "${TRACES[@]}"; do
                for job in "${NUM_JOBS[@]}"; do
                    bash ../../nvm_tools/"${SETUPS[$STEP]}" "${BRANCHES[$STEP]}" "0"
                    
                    sleep 1

                    BW=$(../../nvm_tools/replay -f /mnt/sdb/FIU_Traces/"$TRACE" -d /mnt/pmem0/ -o rw -g null -t "$job" -c "$cblks" | grep "Bandwidth" | awk '{print $9}')
                    
                    table_add_row "$TABLE_NAME" "$file_system $TRACE $cblks $job $BW"  
                done
            done
            STEP=$((STEP + 1))
        done
    done
done

