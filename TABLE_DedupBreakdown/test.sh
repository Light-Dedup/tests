#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
FILE_SIZE=( 4096 )
NUM_JOBS=( 1 )
mkdir -p "$ABS_PATH"/M_DATA
TABLE_NAME="$ABS_PATH/breakdown-table"
VERSIONS="$ABS_PATH/versions"

table_create "$TABLE_NAME" "system whole_time fp_time IO_time cmp_time others bw" 
table_create "$VERSIONS" "system version" 

loop=1
if [ "$1" ]; then
    loop=$1
fi

for ((i=1; i <= loop; i++))
do
    for fsize in "${FILE_SIZE[@]}"; do
        for job in "${NUM_JOBS[@]}"; do
            OUTPUT=$ABS_PATH/M_DATA/"$i-$fsize-$job"
            EACH_SIZE=$(split_workset "$fsize" "$job")
            sudo dmesg -C

            # original-first
            VER1=$(bash ../../nvm_tools/setup_nova.sh "original" "1" | grep "COMMITID" | sed 's/COMMITID: //g')
            BW=$(sudo fio -directory=/mnt/pmem0 -fallocate=none -direct=1 -iodepth 1 -rw=write -ioengine=sync -bs=2M -thread -numjobs="$job" -size="${EACH_SIZE}M" -name=test --dedupe_percentage=0 -group_reporting -randseed="$i" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)

            cat /proc/fs/NOVA/pmem0/timing_stats > "$OUTPUT-NOVA"

            whole_time=$(( 4 * 1000 * 1000 * 1000 / (BW * 1024) )) 
            io_time=$(nova_attr_average_stats "memcpy_write_nvmm" "$OUTPUT-NOVA")
            io_time=$((io_time/512)) 
            fp_time=0
            cmp_time=0
            others=$((whole_time - io_time - fp_time - cmp_time))
            
            table_add_row "$TABLE_NAME" "NOVA $whole_time $fp_time $io_time $cmp_time $others $BW"     
            table_add_row "$VERSIONS" "NOVA $VER1 "          

            # no-prefetch-speculation-first
            VER2=$(bash ../../nvm_tools/setup_nova.sh "no-prefetch-speculation-precmp" "1" | grep "COMMITID" | sed 's/COMMITID: //g')
            BW=$(sudo fio -directory=/mnt/pmem0 -fallocate=none -direct=1 -iodepth 1 -rw=write -ioengine=sync -bs=2M -thread -numjobs="$job" -size="${EACH_SIZE}M" -name=test --dedupe_percentage=0 -group_reporting -randseed="$i" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)

            cat /proc/fs/NOVA/pmem0/timing_stats > "$OUTPUT-NO-SPECULATION-1"

            whole_time=$(( 4 * 1000 * 1000 * 1000 / (BW * 1024) )) 
            io_time=$(nova_attr_average_stats "memcpy_data_block" "$OUTPUT-NO-SPECULATION-1") 
            fp_time=$(nova_attr_average_stats "fp_calc" "$OUTPUT-NO-SPECULATION-1")
            cmp_time=$(nova_attr_average_stats "memcmp" "$OUTPUT-NO-SPECULATION-1")
            others=$((whole_time - io_time - fp_time - cmp_time))
            
            table_add_row "$TABLE_NAME" "NO-SPECULATION-First $whole_time $fp_time $io_time $cmp_time $others $BW"          
            
            # no-prefetch-speculation-second
            echo 1 > /proc/fs/NOVA/pmem0/timing_stats  
            BW=$(sudo fio -directory=/mnt/pmem0 -fallocate=none -direct=1 -iodepth 1 -rw=write -ioengine=sync -bs=2M -thread -numjobs="$job" -size="${EACH_SIZE}M" -name=test --dedupe_percentage=0 -group_reporting -randseed="$i" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)

            cat /proc/fs/NOVA/pmem0/timing_stats > "$OUTPUT-NO-SPECULATION-2"

            whole_time=$(( 4 * 1000 * 1000 * 1000 / (BW * 1024) )) 
            io_time=$(nova_attr_average_stats "memcpy_data_block" "$OUTPUT-NO-SPECULATION-2") 
            fp_time=$(nova_attr_average_stats "fp_calc" "$OUTPUT-NO-SPECULATION-2")
            cmp_time=$(nova_attr_average_stats "memcmp" "$OUTPUT-NO-SPECULATION-2")
            others=$((whole_time - io_time - fp_time - cmp_time))
            
            table_add_row "$TABLE_NAME" "NO-SPECULATION-Second $whole_time $fp_time $io_time $cmp_time $others $BW"
            table_add_row "$VERSIONS" "NO-PREFETCH-SPECULTAION $VER2"          
        done
    done
done
