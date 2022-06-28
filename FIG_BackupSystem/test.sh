#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
NUM_JOBS=( 1 2 4 8 16 )

FILE_SYSTEMS=( "Light-Dedup" "Light-Dedup(SHA256)" "NV-Dedup" "NOVA")
SETUPS=( "setup_nova.sh" "setup_nova.sh" "setup_nvdedup.sh" "setup_nova.sh" )
BRANCHES=( "master" "sha256" "master" "original" )

SYN_TABLE_NAME="$ABS_PATH/performance-comparison-table-SYN"
WEB_TABLE_NAME="$ABS_PATH/performance-comparison-table-WEB"
table_create "$SYN_TABLE_NAME" "file_system num_job SYN-bandwidth(MiB/s)"
table_create "$WEB_TABLE_NAME" "file_system num_job WEB-bandwidth(MiB/s)"

STEP=0
for file_system in "${FILE_SYSTEMS[@]}"; do
    for job in "${NUM_JOBS[@]}"; do
        SETUP=${SETUPS[$STEP]}
        bash ../../nvm_tools/"$SETUP"

        python3 backup.py ./exmdata/SYN ./exmpmem ./exmsplit "$job" | awk '{print $3}' | sed 's/MiB\/s//g' > ./tmp
        awk -i inplace '{print v1 " " v2 " " $0}' v1="$file_system" v2="$job" ./tmp
        cat ./tmp >> "$SYN_TABLE_NAME"
        
        python3 backup.py ./exmdata/WEB ./exmpmem ./exmsplit "$job" | awk '{print $3}' | sed 's/MiB\/s//g' > ./tmp 
        awk -i inplace '{print v1 " " v2 " " $0}' v1="$file_system" v2="$job" ./tmp
        cat ./tmp >> "$WEB_TABLE_NAME"
        
        rm ./tmp
    done
    STEP=$((STEP + 1))
done


