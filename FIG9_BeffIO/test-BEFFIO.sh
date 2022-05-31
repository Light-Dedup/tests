#!/usr/bin/env bash

BRANCHES=( "master" "original")

PROCESSES=( 1 2 4 8 16 )

cd ../../bin || exit
echo "branch process block bw(MiB/s)" > ../tests/FIG9_BeffIO/b_eff_io-table

for branch in "${BRANCHES[@]}"; do
    for process in "${PROCESSES[@]}"; do
        git checkout "$branch"
        make -j"$(nproc)"
        sudo umount /mnt/pmem
        sudo bash setup.sh
        sudo chmod -R 777 /mnt/pmem
        block_start=$(df -B 4K | grep /dev/pmem0 | awk '{print $3}')
        
        bw=$(mpirun -np "$process" b_eff_io -MB 2048 -MT $(( 2048 * process )) -noshared -rewrite -N "$process" -T 120 -p /mnt/pmem -f Hello -keep | grep "b_eff_io =" | awk '{print $3}')
        
        block_end=$(df -B 4K | grep /dev/pmem0 | awk '{print $3}')
        block=$(( block_end - block_start ))
        echo "$branch $process $block $bw" >> ../tests/FIG9_BeffIO/b_eff_io-table
    done
done

