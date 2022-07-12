#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA
FILE_SIZE=( $((64 * 1024)) ) # 128 * 1024
NUM_JOBS=( 1 2 4 8 16 )

FILE_SYSTEMS=( "Prefetch-Next+Speculation" "Prefetch-Next" "Speculation" "Prefetch-Current" "Naive")
TIMERS=( "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" )
BRANCHES=( "master" "no-speculation" "no-prefetch" "prefetch-current" "no-prefetch-speculation" )


TABLE_NAME="$ABS_PATH/performance-comparison-table"
table_create "$TABLE_NAME" "file_system num_job first_bandwidth(MiB/s) second_bandwidth(MiB/s) second_cmp_lat(ns) second_fp_lat(ns) second_others_lat(ns) second_lat(ns)"

loop=1
if [ "$1" ]; then
    loop=$1
fi

for ((i=1; i <= loop; i++))
do
    STEP=0
    for file_system in "${FILE_SYSTEMS[@]}"; do
        for fsize in "${FILE_SIZE[@]}"; do
            for job in "${NUM_JOBS[@]}"; do
                EACH_SIZE=$(split_workset "$fsize" "$job")
                TIMER=${TIMERS[$STEP]}

                bash ../../nvm_tools/"${TIMER}" "${BRANCHES[$STEP]}" "1"
                
                BW1=$(sudo fio -directory=/mnt/pmem0 -fallocate=none -direct=1 -iodepth 1 -rw=write -ioengine=sync -bs=2M -thread -numjobs="$job" -size="${EACH_SIZE}M" -name=test --dedupe_percentage=0 -group_reporting -randseed="$i" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)

                echo 1 > /proc/fs/NOVA/pmem0/timing_stats  
                
                BW2=$(sudo fio -directory=/mnt/pmem0 -fallocate=none -direct=1 -iodepth 1 -rw=write -ioengine=sync -bs=2M -thread -numjobs="$job" -size="${EACH_SIZE}M" -name=test --dedupe_percentage=0 -group_reporting -randseed="$i" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)
                
                cat /proc/fs/NOVA/pmem0/timing_stats > "$ABS_PATH"/M_DATA/OUTPUT-"$i"
                
                # whole_time=$(( EACH_SIZE * 1000 * 1000 * 1000 / ("$BW2") ))  
                whole_time=$(nova_attr_time_stats "cow_write" "$ABS_PATH"/M_DATA/OUTPUT-"$i")   
                fp_time=$(nova_attr_time_stats "fp_calc" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
                cmp_time=$(nova_attr_time_stats "memcmp" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
                cmp_user=$(nova_attr_time_stats "cmp_user" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
                cmp_time=$((cmp_time + cmp_user)) 
                others=$((whole_time - fp_time - cmp_time))
                
                table_add_row "$TABLE_NAME" "$file_system $job $BW1 $BW2 $cmp_time $fp_time $others $whole_time"     
            done
        done
        STEP=$((STEP + 1))
    done
done

