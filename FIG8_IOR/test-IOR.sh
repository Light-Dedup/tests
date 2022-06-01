#!/usr/bin/env bash

BRANCHES=( "master" "original")
PROCESSES=( 1 2 4 8 16 )

cd ../../Light-Dedup || exit
echo "branch process GiB_PER_THREAD block write_bandwidth(MiB/s)" > ../tests/FIG8_IOR/ior-table

for branch in "${BRANCHES[@]}"; do
    for process in "${PROCESSES[@]}"; do
        git checkout "$branch"
        sudo umount /mnt/pmem
        sudo bash setup.sh
        block_start=$(df -B 4K | grep /dev/pmem0 | awk '{print $3}')
        sudo chmod -R 777 /mnt/pmem

        case "${process}" in
            1)
                GiB_PER_THREAD=128
            ;;
            2)
                GiB_PER_THREAD=64
            ;;
            4)
                GiB_PER_THREAD=32
            ;;
            8)
                GiB_PER_THREAD=16
            ;;
            16)
                GiB_PER_THREAD=8
            ;;
        esac
        # ior version 3.3.0
        WRITE_PERF=$(mpirun -np "$process" ior -t 4K -b 4K -s $((1024*256*GiB_PER_THREAD)) -F -l offset -o /mnt/pmem/test -w -keep | grep write | sed -n 2p | awk '{print $4}') 
        block_end=$(df -B 4K | grep /dev/pmem0 | awk '{print $3}')
        block=$(( block_end - block_start ))
        echo "$branch $process $GiB_PER_THREAD $block $WRITE_PERF" >> ../tests/FIG8_IOR/ior-table   
    done
done


