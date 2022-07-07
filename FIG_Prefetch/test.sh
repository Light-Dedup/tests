#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA
DUP_RATES=( 0 25 50 75 )
FILE_SIZE=( $((128 * 1024)) ) # 128 * 1024
NUM_JOBS=( 1 2 4 8 16 )

# Computaion Read Parallism: 
# 1. prefetch-current: Hint: Predict => (last) Prefetch -> Copy -> Calc -> Lookup compare  (Computaion / Read Parallism: Copy Calc Lookup || Prefetch)
# 2. speculation: By pass "Copy Calc Lookup" and compare (last) Hint-Offset  => Eliminate Computation, Read  
# 3. speculation+prefetch-current: (last) Prefetch -> By pass "Copy Calc Lookup" and compare (last) Hint-Offset  => Content-Comparing Read and Current Block Prefecth Read parallism.
# 4. master: By pass "Copy Calc Lookup" and compare (last) Hint-Offset + Prefetch (cur) Hint-Offset => Content-Comparing Read and Next Block Prefecth Read parallism.

FILE_SYSTEMS=( "Prefetch-Next+Speculation" "Speculation" "Prefetch-Current")
TIMERS=( "fio_nova.sh" "fio_nova.sh" "fio_nova.sh" )
BRANCHES=( "master" "no-prefetch" "prefetch-current" )


TABLE_NAME="$ABS_PATH/performance-comparison-table"
table_create "$TABLE_NAME" "file_system dup_rate num_job bandwidth(MiB/s)"

loop=1
if [ "$1" ]; then
    loop=$1
fi

for ((i=1; i <= loop; i++))
do
    for dup_rate in "${DUP_RATES[@]}"; do
        STEP=0
        for file_system in "${FILE_SYSTEMS[@]}"; do
            for fsize in "${FILE_SIZE[@]}"; do
                for job in "${NUM_JOBS[@]}"; do
                    EACH_SIZE=$(split_workset "$fsize" "$job")
                    TIMER=${TIMERS[$STEP]}

                    BW=$(bash ../../nvm_tools/"$TIMER" "$job" "${EACH_SIZE}"M "$dup_rate" "${BRANCHES[$STEP]}" "0" "2M" | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../../nvm_tools/to_MiB_s)
                    
                    table_add_row "$TABLE_NAME" "$file_system $dup_rate $job $BW"     
                done
            done
            STEP=$((STEP + 1))
        done
    done
done

