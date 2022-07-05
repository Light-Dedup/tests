#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"

ABS_PATH=$(where_is_script "$0")

FSCRIPT_PRE_FIX=$ABS_PATH/"SCRIPTS"

mkdir -p "$ABS_PATH"/M_DATA

FILE_SYSTEMS=( "Light-Dedup" "Light-Dedup(SHA256)" "NV-Dedup" "NOVA" )
SETUPS=( "setup_nova.sh" "setup_nova.sh" "setup_nvdedup.sh" "setup_nova.sh" )
BRANCHES=( "master" "sha256" "master" "original" )
FILE_BENCHES=( "fileserver.f" "varmail.f" "webproxy.f" "webserver.f" )

TABLE_NAME="$ABS_PATH/performance-comparison-table"
table_create "$TABLE_NAME" "file_bench file_system iops block"

loop=1
if [ "$1" ]; then
    loop=$1
fi

for ((i=1; i <= loop; i++))
do
    for file_bench in "${FILE_BENCHES[@]}"; do
        STEP=0
        for file_system in "${FILE_SYSTEMS[@]}"; do
            bash ../../nvm_tools/"${SETUPS[$STEP]}" "${BRANCHES[$STEP]}" "0"
            
            block_start=$(get_pmem_block pmem0)
            # /usr/local/filebench/filebench
            sudo /usr/local/filebench/filebench -f "$FSCRIPT_PRE_FIX"/"$file_bench" | tee "$ABS_PATH"/M_DATA/"$file_bench"-"$file_system"
            block_end=$(get_pmem_block pmem0)

            iops=$(filebench_attr_iops "$ABS_PATH"/M_DATA/"$file_bench"-"$file_system")
        
            table_add_row "$TABLE_NAME" "$file_system $file_bench $iops $((block_end - block_start))"     
            STEP=$((STEP + 1))
        done
    done
done
