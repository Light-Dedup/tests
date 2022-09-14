#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA
FILE_SIZE=( $((32 * 1024)) $((64 * 1024)) $((128 * 1024)) ) # 128 * 1024
NUM_JOBS=( 32 )

FILE_SYSTEMS=( "Light-Dedup-NORMAL" "Light-Dedup-FAILURE" "NOVA-OPT-NORMAL" "NOVA-OPT-FAILURE" )
TIMERS=( "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" "setup_nova.sh" )
BRANCHES=( "master" "failure-recovery" "original" "failure-recovery-original" )

TABLE_NAME="$ABS_PATH/performance-comparison-table"
table_create "$TABLE_NAME" "file_system file_size umount_time recovery"

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

                bash ../../nvm_tools/"$TIMER" "${BRANCHES[$STEP]}" "0"
                _=$(bash ../../nvm_tools/helper/fio.sh "$job" "${EACH_SIZE}"M 0)
                UMOUNT_TIME=$( (time sudo umount /mnt/pmem0) 2>&1 | grep real | awk '{print $2}' )
                RECOVERY_TIME=$( (time sudo mount -t NOVA -o wprotect,data_cow /dev/pmem0 /mnt/pmem0) 2>&1 | grep real | awk '{print $2}' )

                table_add_row "$TABLE_NAME" "$file_system $fsize $UMOUNT_TIME $RECOVERY_TIME"
            done
        done
        STEP=$((STEP + 1))
    done
done

