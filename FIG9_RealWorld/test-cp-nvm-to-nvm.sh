#!/usr/bin/env bash

source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA
NUM_JOBS=( 1 8 16 )

FILE_SYSTEMS=( "Light-Dedup" "Naive" "DeNOVA" "NV-Dedup" "NOVA" )
SETUPS=( "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" "setup_nvdedup.sh" "setup_nova.sh" )
BRANCHES=( "master" "no-prefetch-speculation-precmp" "denova" "master" "original" )

TABLE_NAME="$ABS_PATH/performance-comparison-table-cp-nvm2nvm"
table_create "$TABLE_NAME" "file_system num_job first_bw second_bw"

STEP=0

# warm up SSD
bash ../../nvm_tools/"${SETUPS[$STEP]}" "${BRANCHES[$STEP]}" "0"
BW1=$(bash ./mcp.sh "/usr/src/linux-nova-master" "/mnt/pmem0/src-linux-1" "1")
BW2=$(bash ./mcp.sh "/mnt/pmem0/src-linux-1" "/mnt/pmem0/src-linux-2" "1")

# start test
loop=1
if [ "$1" ]; then
    loop=$1
fi

for ((i=1; i <= loop; i++))
do
    STEP=0
    for file_system in "${FILE_SYSTEMS[@]}"; do
        for job in "${NUM_JOBS[@]}"; do

            bash ../../nvm_tools/"${SETUPS[$STEP]}" "${BRANCHES[$STEP]}" "0"
            # Code Here
            BW1=$(bash ./mcp.sh "/usr/src/linux-nova-master" "/mnt/pmem0/src-linux-1" "$job")
            BW2=$(bash ./mcp.sh "/mnt/pmem0/src-linux-1" "/mnt/pmem0/src-linux-2" "$job")
            
            table_add_row "$TABLE_NAME" "$file_system $job $BW1 $BW2"     
        done
        STEP=$((STEP + 1))
    done
done
