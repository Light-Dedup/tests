#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA

# Single Thread with Breakdown
FILE_SYSTEMS=( "Naive" "Prefetch-Cmp-64" "Prefetch-Cmp-256-64" "Prefetch-Current" "Speculation" "Prefetch-Next" )
TIMERS=( "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" )
BRANCHES=( "no-prefetch-speculation-precmp" "no-prefetch-speculation-precmp_256B" "no-prefetch-speculation" "prefetch-current" "speculation" "no-transition" )

TABLE_NAME="$ABS_PATH/performance-comparison-table"
table_create "$TABLE_NAME" "file_system iops second_cmp_lat(ns) second_fp_lat(ns) second_prefetch_lat(ns) second_lookup_lat(ns) second_others_lat(ns) second_lat(ns)"

FSCRIPT_PRE_FIX=$ABS_PATH/"SCRIPTS"

VERSIONS="$ABS_PATH/version"
table_create "$VERSIONS" "file_system version"

loop=1
if [ "$1" ]; then
    loop=$1
fi
for ((i=1; i <= loop; i++))
do
    STEP=0
    for file_system in "${FILE_SYSTEMS[@]}"; do
        TIMER=${TIMERS[$STEP]}

        VER=$(bash ../../nvm_tools/"${TIMER}" "${BRANCHES[$STEP]}" "1" | grep "COMMITID" | sed 's/COMMITID: //g')
        
        sudo /usr/local/filebench/filebench -f "$FSCRIPT_PRE_FIX"/"fileserver.f" | tee "$ABS_PATH"/M_DATA/"fileserver.f"-"$file_system"

        iops=$(filebench_attr_iops "$ABS_PATH"/M_DATA/"fileserver.f"-"$file_system")
        
        cat /proc/fs/NOVA/pmem0/timing_stats > "$ABS_PATH"/M_DATA/OUTPUT-"$i"
        
        # whole_time=$(( EACH_SIZE * 1000 * 1000 * 1000 / ("$BW2") ))  
        whole_time=$(nova_attr_time_stats "cow_write" "$ABS_PATH"/M_DATA/OUTPUT-"$i")   
        fp_time=$(nova_attr_time_stats "fp_calc" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
        lookup_time=$(nova_attr_time_stats "mem_bucket_find" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
        cmp_time=$(nova_attr_time_stats "memcmp" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
        cmp_user=$(nova_attr_time_stats "cmp_user" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
        prefetch_cmp=$(nova_attr_time_stats "prefetch_cmp" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
        prefetch_cmp=$((prefetch_cmp))
        prefetch_next_stage1=$(nova_attr_time_stats "prefetch_next_stage_1" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
        prefetch_next_stage1=$((prefetch_next_stage1))
        prefetch_next_stage2=$(nova_attr_time_stats "prefetch_next_stage_2" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
        prefetch_next_stage2=$((prefetch_next_stage1))
        prefetch_stage1=$(nova_attr_time_stats "prefetch_stage_1" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
        prefetch_stage1=$((prefetch_stage1))
        prefetch_stage2=$(nova_attr_time_stats "prefetch_stage_2" "$ABS_PATH"/M_DATA/OUTPUT-"$i")
        prefetch_stage2=$((prefetch_stage2))
        
        prefetch_time=$((prefetch_next_stage1 + prefetch_next_stage2 + prefetch_stage1 + prefetch_stage2))
        cmp_time=$((cmp_time + cmp_user + prefetch_cmp)) 
        others=$((whole_time - fp_time - cmp_time - prefetch_time - lookup_time))
        
        table_add_row "$TABLE_NAME" "$file_system $iops $cmp_time $fp_time $prefetch_time $lookup_time $others $whole_time" 
        table_add_row "$VERSIONS" "$file_system $VER"    

        STEP=$((STEP + 1))
    done
done

