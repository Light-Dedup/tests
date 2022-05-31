#!/usr/bin/env bash

source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA
NUM_JOBS=( 1 2 4 8 16 )

FILE_SYSTEMS=( "Light-Dedup" "Light-Dedup(SHA256)" "NV-Dedup" "NOVA")
SETUPS=( "setup_nova.sh" "setup_nova.sh" "setup_nvdedup.sh" "setup_nova.sh")
BRANCHES=( "master" "sha256" "master" "original" )

TABLE_NAME="$ABS_PATH/performance-comparison-table-NV-Dedup"
table_create "$TABLE_NAME" "file_system num_job first_bw second_bw"

STEP=0
for file_system in "${FILE_SYSTEMS[@]}"; do
    for job in "${NUM_JOBS[@]}"; do

        bash ../../nvm_tools/"${SETUPS[$STEP]}" "${BRANCHES[$STEP]}" "0"
        # Code Here
        BW1=$(bash ./mcp.sh "/usr/src/linux-nova-master" "/mnt/pmem1/src-linux-1" "$job")
        BW2=$(bash ./mcp.sh "/usr/src/linux-nova-master" "/mnt/pmem1/src-linux-2" "$job")

        table_add_row "$TABLE_NAME" "$file_system $job $BW1 $BW2"     
    done
    STEP=$((STEP + 1))
done

