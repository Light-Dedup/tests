#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA

FILE_SIZE=( $((64)) ) 
NUM_JOBS=(1)      

FILE_SYSTEMS=( "Volatile-FP" "Simple-Random")
TIMERS=( "setup_nova.sh" "setup_nova.sh")
BRANCHES=( "volatile-fpentry" "persistent-bucket" )

TABLE_NAME_FIRST="$ABS_PATH/first-table-simple-random"
TABLE_NAME_SECOND="$ABS_PATH/second-table-simple-random"

table_create "$TABLE_NAME_FIRST" "file_system file_size num_job read write t"
table_create "$TABLE_NAME_SECOND" "file_system file_size num_job read write t"

for job in "${NUM_JOBS[@]}"; do
    STEP=0
    for file_system in "${FILE_SYSTEMS[@]}"; do
        for fsize in "${FILE_SIZE[@]}"; do
            EACH_SIZE=$(split_workset "$fsize" "$job")
            TIMER=${TIMERS[$STEP]}

            bash ../../nvm_tools/"$TIMER" "${BRANCHES[$STEP]}" "0"
            OUTPUT=$(bash ../../nvm_tools/percore_amount_simple_random.sh "/mnt/pmem1" "$job" "${EACH_SIZE}" 0)
            FIRST_TIME=$(echo "$OUTPUT" | grep FirstTime | awk '{print $2}')
            FIRST_READ=$(echo "$OUTPUT" | grep FirstRead | awk '{print $2}')
            FIRST_WRITE=$(echo "$OUTPUT" | grep FirstWrite | awk '{print $2}')
            SECOND_TIME=$(echo "$OUTPUT" | grep SecondTime | awk '{print $2}')
            SECOND_READ=$(echo "$OUTPUT" | grep SecondRead | awk '{print $2}')
            SECOND_WRITE=$(echo "$OUTPUT" | grep SecondWrite | awk '{print $2}')


            table_add_row "$TABLE_NAME_FIRST" "$file_system $fsize $job $FIRST_READ $FIRST_WRITE $FIRST_TIME"

            table_add_row "$TABLE_NAME_SECOND" "$file_system $fsize $job $SECOND_READ $SECOND_WRITE $SECOND_TIME"

        done
        STEP=$((STEP + 1))
    done
done 


