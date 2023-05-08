#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
FILE_SIZE=( 4096 )
BRANCHES=( "master" "no-prefetch-speculation-precmp" )
NUM_JOBS=( 1 )
mkdir -p "$ABS_PATH"/M_DATA
TABLE_NAME="$ABS_PATH/breakdown-table"
VERSIONS="$ABS_PATH/versions"

table_create "$TABLE_NAME" "system whole_time job fp_time IO_time cmp_time others bw" 
table_create "$VERSIONS" "system version" 

loop=1
if [ "$1" ]; then
    loop=$1
fi

for ((i=1; i <= loop; i++))
do
    for fsize in "${FILE_SIZE[@]}"; do
        for job in "${NUM_JOBS[@]}"; do
            for branch in "${BRANCHES[@]}"; do
                OUTPUT=$ABS_PATH/M_DATA/"$i-$fsize-$job"
                EACH_SIZE=$(split_workset "$fsize" "$job")
                sudo dmesg -C

                # original-first
                VER1=$(bash ../../nvm_tools/setup_nova.sh "original" "1" | grep "COMMITID" | sed 's/COMMITID: //g')
                sudo mkdir -p /mnt/pmem0/origin-first
                BW=$(sudo fio -directory=/mnt/pmem0/origin-first -fallocate=none -direct=1 -iodepth 1 -rw=write -ioengine=sync -bs=2M -thread -numjobs="$job" -size="${EACH_SIZE}M" -name=test --dedupe_percentage=0 -group_reporting -randseed="$i" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)

                cat /proc/fs/NOVA/pmem0/timing_stats > "$OUTPUT-NOVA"

                whole_time=$(nova_attr_time_stats "cow_write" "$OUTPUT-NOVA")
                io_time=$(nova_attr_time_stats "memcpy_write_nvmm" "$OUTPUT-NOVA")
                fp_time=0
                cmp_time=0
                others=$((whole_time - io_time - fp_time - cmp_time))
                
                table_add_row "$TABLE_NAME" "NOVA $whole_time $job $fp_time $io_time $cmp_time $others $BW"     
                table_add_row "$VERSIONS" "NOVA $VER1 "          

                # no-prefetch-speculation-first
                VER2=$(bash ../../nvm_tools/setup_nova.sh "$branch" "1" | grep "COMMITID" | sed 's/COMMITID: //g')
                sudo mkdir -p /mnt/pmem0/first
                BW=$(sudo fio -directory=/mnt/pmem0/first -fallocate=none -direct=1 -iodepth 1 -rw=write -ioengine=sync -bs=2M -thread -numjobs="$job" -size="${EACH_SIZE}M" -name=test --dedupe_percentage=0 -group_reporting -randseed="$i" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)

                cat /proc/fs/NOVA/pmem0/timing_stats > "$OUTPUT-$branch-1"

                whole_time=$(nova_attr_time_stats "cow_write" "$OUTPUT-$branch-1")
                io_time=$(nova_attr_time_stats "memcpy_data_block" "$OUTPUT-$branch-1") 
                fp_time=$(nova_attr_time_stats "fp_calc" "$OUTPUT-$branch-1")
                cmp_user=$(nova_attr_time_stats "cmp_user" "$OUTPUT-$branch-1")
                cmp_user=$((cmp_user))
                prefetch_cmp=$(nova_attr_time_stats "prefetch_cmp" "$OUTPUT-$branch-1")
                prefetch_cmp=$((prefetch_cmp))
                cmp_time=$(nova_attr_time_stats "memcmp" "$OUTPUT-$branch-1")
                cmp_time=$((cmp_time + cmp_user + prefetch_cmp))
                others=$((whole_time - io_time - fp_time - cmp_time))
                
                table_add_row "$TABLE_NAME" "$branch-First $whole_time $job $fp_time $io_time $cmp_time $others $BW"          
                
                # no-prefetch-speculation-second
                sudo mkdir -p /mnt/pmem0/second
                echo 1 > /proc/fs/NOVA/pmem0/timing_stats  
                BW=$(sudo fio -directory=/mnt/pmem0/second -fallocate=none -direct=1 -iodepth 1 -rw=write -ioengine=sync -bs=2M -thread -numjobs="$job" -size="${EACH_SIZE}M" -name=test --dedupe_percentage=0 -group_reporting -randseed="$i" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)

                cat /proc/fs/NOVA/pmem0/timing_stats > "$OUTPUT-$branch-2"

                whole_time=$(nova_attr_time_stats "cow_write" "$OUTPUT-$branch-2")
                io_time=$(nova_attr_time_stats "memcpy_data_block" "$OUTPUT-$branch-2") 
                fp_time=$(nova_attr_time_stats "fp_calc" "$OUTPUT-$branch-2")
                cmp_user=$(nova_attr_time_stats "cmp_user" "$OUTPUT-$branch-2")
                cmp_user=$((cmp_user))
                prefetch_cmp=$(nova_attr_time_stats "prefetch_cmp" "$OUTPUT-$branch-2")
                prefetch_cmp=$((prefetch_cmp))
                cmp_time=$(nova_attr_time_stats "memcmp" "$OUTPUT-$branch-2")
                cmp_time=$((cmp_time + cmp_user + prefetch_cmp))
                others=$((whole_time - io_time - fp_time - cmp_time))
                
                table_add_row "$TABLE_NAME" "$branch-Second $whole_time $job $fp_time $io_time $cmp_time $others $BW"
                table_add_row "$VERSIONS" "$branch $VER2"       
            done   
        done
    done
done
