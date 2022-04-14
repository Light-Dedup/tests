#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA
FILE_SIZE=( $((128)) ) # 128 GB
NUM_JOBS=( 1 )

FILE_SYSTEMS=( "Original" "Region-based" "Fine-grained"  )
TIMERS=( "aging_amount.sh" "aging_amount.sh" "aging_amount.sh" )
BRANCHES=( "original" "master" "entry-based" )


AGING_RATIO=(50)

TABLE_NAME_NEWLY="$ABS_PATH/newly_table"
TABLE_NAME_AGING="$ABS_PATH/aging_table"
table_create "$TABLE_NAME_AGING" "file_system file_size read write lat bw"
table_create "$TABLE_NAME_NEWLY" "file_system file_size read write lat bw"

for job in "${NUM_JOBS[@]}"; do
    for age in "${AGING_RATIO[@]}"; do
        STEP=0
        for file_system in "${FILE_SYSTEMS[@]}"; do
            for fsize in "${FILE_SIZE[@]}"; do
                TIMER=${TIMERS[$STEP]}
                
                OUTPUT=$(bash ../../nvm_tools/"$TIMER" "$job" "${EACH_SIZE}"M 0 "${BRANCHES[$STEP]}" "$fsize" "$age" "0x120")
              
                READS=$(echo "$OUTPUT" | grep MediaReads | awk '{print $2}')
                WRITES=$(echo "$OUTPUT" | grep MediaWrites | awk '{print $2}')
                NewlyWriteBW=$(echo "$OUTPUT" | grep NewlyWriteBW | awk '{print $2}')
                NewlyWriteLAT=$(echo "$OUTPUT" | grep NewlyWriteLAT | awk '{print $2}')
                AgingWriteBW=$(echo "$OUTPUT" | grep AgingWriteBW | awk '{print $2}')
                AgingWriteLAT=$(echo "$OUTPUT" | grep AgingWriteLAT | awk '{print $2}')
                NewlyRead=$(echo "$READS" | sed -n "1p") 
                AgingRead=$(echo "$READS" | sed -n "2p") 
                NewlyWrite=$(echo "$WRITES" | sed -n "1p") 
                AgingWrite=$(echo "$WRITES" | sed -n "2p") 
                
                
                table_add_row "$TABLE_NAME_NEWLY" "$file_system file_system ${fsize}G $NewlyRead $NewlyWrite $NewlyWriteLAT  $NewlyWriteBW"     
                
                table_add_row "$TABLE_NAME_AGING" "$file_system file_system ${fsize}G $AgingRead $AgingWrite $AgingWriteLAT $AgingWriteBW"
   
            done
            STEP=$((STEP + 1))
        done
    done
done 


