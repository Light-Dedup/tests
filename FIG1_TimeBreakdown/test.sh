#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
DEDUP_RATES=( 0 25 50 75 )
FILE_SIZE=( 4096 )
NUM_JOBS=( 1 )
mkdir -p "$ABS_PATH"/M_DATA
TABLE_NAME="$ABS_PATH/breakdown-table"

table_create "$TABLE_NAME" "dup_rate whole_time strong_fp_time weak_fp_time IO_time others bw" 

loop=1
if [ "$1" ]; then
    loop=$1
fi

for ((i=1; i <= loop; i++))
do
    for dup_rate in "${DEDUP_RATES[@]}"; do
        for fsize in "${FILE_SIZE[@]}"; do
            for job in "${NUM_JOBS[@]}"; do
                OUTPUT=$ABS_PATH/M_DATA/"$dup_rate-$fsize-$job"
                EACH_SIZE=$(split_workset "$fsize" "$job")
                sudo dmesg -C
                BW=$(bash ../../nvm_tools/fio_nvdedup.sh "$job" "${EACH_SIZE}"M "$dup_rate" "master" "1" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)
            
                cat /proc/fs/NOVA/pmem0/timing_stats > "$OUTPUT"
                
                whole_time=$(nova_attr_time_stats "do_cow_write" "$OUTPUT") 
                io_time=$(nova_attr_time_stats "memcpy_write_nvmm" "$OUTPUT") 
                strong_fp_time=$(nova_attr_time_stats "strong_fingerprint_calculation" "$OUTPUT") 
                weak_fp_time=$(nova_attr_time_stats "weak_fingerprint_calculation" "$OUTPUT") 
                others=$((whole_time - io_time - strong_fp_time - weak_fp_time))
                
                table_add_row "$TABLE_NAME" "$dup_rate $whole_time $strong_fp_time $weak_fp_time $io_time $others $BW"          
            done
        done
    done
done
