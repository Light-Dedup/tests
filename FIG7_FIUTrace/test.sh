#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA
DUP_RATES=( 0 25 50 75 )
FILE_SIZE=( $((128 * 1024)) ) # 128 * 1024
NUM_JOBS=( 1 2 4 8 16 )


FILE_SYSTEMS=( "Light-Dedup" "Light-Dedup(SHA256)" "NV-Dedup" "NOVA")
SETUPS=( "setup_nova.sh" "setup_nova.sh" "setup_nvdedup.sh" "setup_nova.sh" )
BRANCHES=( "master" "sha256" "master" "original" )
TRACES_PREFIXS=( "homes-110108-112108" "webmail+online.cs.fiu.edu-110108-113008" "cheetah.cs.fiu.edu-110108-113008" )
TRACES_RANGE_START=( 1 1 1 )
TRACES_RANGE_END=( 21 21 2)

TABLE_NAME="$ABS_PATH/performance-comparison-table"
table_create "$TABLE_NAME" "file_system trace bandwidth(MiB/s)"

loop=1
if [ "$1" ]; then
    loop=$1
fi

for ((i=1; i <= loop; i++))
do
    STEP=0
    for file_system in "${FILE_SYSTEMS[@]}"; do
        TRACE_STEP=0
        for TRACES_PREFIX in "${TRACES_PREFIXS[@]}"; do
            bash ../../nvm_tools/"${SETUPS[$STEP]}" "${BRANCHES[$STEP]}" "0"
            RANGE_START=${TRACES_RANGE_START[$TRACE_STEP]}
            RANGE_END=${TRACES_RANGE_END[$TRACE_STEP]}

            BW=$(python3 ./replay.py /home/deadpool/Downloads/FIU_Traces/"$TRACES_PREFIX".\$n.blkparse "$RANGE_START" "$RANGE_END" | grep "Replay Bandwidth" | awk '{print $3}')
            
            table_add_row "$TABLE_NAME" "$file_system $TRACES_PREFIX $BW"  
            TRACE_STEP=$((TRACE_STEP + 1))
        done
        STEP=$((STEP + 1))
    done
done

