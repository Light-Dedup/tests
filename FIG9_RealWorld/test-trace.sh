#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA

FILE_SYSTEMS=( "Light-Dedup" "Naive" "DeNOVA" "NV-Dedup" "NOVA" )
SETUPS=( "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" "setup_nvdedup.sh" "setup_nova.sh" )
BRANCHES=( "master" "no-prefetch-speculation-precmp" "denova" "master" "original" )
MODES=( "rw" "rw" "a" "rw" "rw" )

# FILE_SYSTEMS=( "Light-Dedup" "Naive" "NOVA" )
# SETUPS=( "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" )
# BRANCHES=( "master" "no-prefetch-speculation-precmp" "original" )
# MODES=( "rw" "rw" "rw" )

NAMES=( "homes-2022-fall-50.hitsztrace" "webmail+online.cs.fiu.edu-110108-113008.1-21.blkparse" "cheetah.cs.fiu.edu-110108-113008.1.blkparse" )
TRACES=( "/mnt/sdb/HITSZ_LAB_Traces/homes-2022-fall-50.hitsztrace" "/mnt/sdb/FIU_Traces/webmail+online.cs.fiu.edu-110108-113008.1-21.blkparse" "/mnt/sdb/FIU_Traces/cheetah.cs.fiu.edu-110108-113008.1.blkparse" )
FMTS=( "hitsz" "fiu" "fiu" )

MAX_C_BLKS=( 1 512 )
NUM_JOBS=( 1 8 )

TABLE_NAME="$ABS_PATH/performance-comparison-table-trace"
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
            TRACE_ID=0
            for TRACE in "${TRACES[@]}"; do
                for job in "${NUM_JOBS[@]}"; do
                    bash ../../nvm_tools/"${SETUPS[$STEP]}" "${BRANCHES[$STEP]}" "0"
                    
                    sleep 1

                    BW=$(../../nvm_tools/replay -f "$TRACE" -d /mnt/pmem0/ -o "${MODES[$STEP]}" -g null -t "$job" -c "$cblks" -m "${FMTS[$TRACE_ID]}" | grep "Bandwidth" | awk '{print $9}')

                    table_add_row "$TABLE_NAME" "$file_system ${NAMES[$TRACE_ID]} $cblks $job $BW"  
                done
                TRACE_ID=$((TRACE_ID + 1))
            done
            STEP=$((STEP + 1))
        done
    done
done

