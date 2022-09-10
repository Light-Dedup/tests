#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA
DUP_RATES=( 0 )
FILE_SIZE=( $((128 * 1024)) ) # 128 * 1024
NUM_JOBS=( 1 )


FILE_SYSTEMS=( "Light-Dedup" "Light-Dedup(SHA256)" "NV-Dedup" "NOVA")
TIMERS=( "setup_nova.sh" "setup_nova.sh" "setup_nvdedup.sh" "setup_nova.sh" )
BRANCHES=( "master" "sha256" "master" "original" )

TABLE_NAME="$ABS_PATH/performance-comparison-table"
table_create "$TABLE_NAME" "file_system dup_rate num_job tail90 tail95 tail99 tail995 tail999 tail9995 tail9999 tail99999 tail999999 tail9999999 tail99999999"

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

                    bash ../../nvm_tools/"$TIMER" "${BRANCHES[$STEP]}" "0"

                    OUTPUT=$(sudo fio -directory=/mnt/pmem0 -fallocate=none -direct=1 -iodepth 1 -rw=write -ioengine=sync -bs=4K -thread -numjobs=$job -size=${EACH_SIZE}M -name=test --dedupe_percentage=0 -nrfiles=128 -group_reporting --percentile_list=90.00:95.00:99.00:99.50:99.90:99.95:99.99:99.999:99.9999:99.99999:99.999999)

                    echo "$OUTPUT" > fio-output
                    tail90=$(python3 extract.py fio-output 90.00)
                    tail95=$(python3 extract.py fio-output 95.00)
                    tail99=$(python3 extract.py fio-output 99.00)
                    tail995=$(python3 extract.py fio-output 99.50)
                    tail999=$(python3 extract.py fio-output 99.90)
                    tail9995=$(python3 extract.py fio-output 99.95)
                    tail9999=$(python3 extract.py fio-output 99.99)
                    tail99999=$(python3 extract.py fio-output 99.999)
                    tail999999=$(python3 extract.py fio-output 99.9999)
                    tail9999999=$(python3 extract.py fio-output 99.99999)
                    tail99999999=$(python3 extract.py fio-output 99.999999)


                    table_add_row "$TABLE_NAME" "$file_system $dup_rate $job $tail90 $tail95 $tail99 $tail995 $tail999 $tail9995 $tail9999 $tail99999 $tail999999 $tail9999999 $tail99999999"    
                done
            done
            STEP=$((STEP + 1))
        done
    done
done

