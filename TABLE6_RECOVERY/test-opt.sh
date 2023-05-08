#!/usr/bin/sh

bash ../../nvm_tools/"setup_nova.sh" "failure-recovery-original"
bash ../../nvm_tools/helper/fio.sh 1 128G 0 && sudo umount /mnt/pmem0 && time sudo mount -t NOVA -o wprotect,data_cow /dev/pmem0 /mnt/pmem0

bash ../../nvm_tools/"setup_nova.sh" "failure-recovery-pure"
bash ../../nvm_tools/helper/fio.sh 1 128G 0 && sudo umount /mnt/pmem0 && time sudo mount -t NOVA -o wprotect,data_cow /dev/pmem0 /mnt/pmem0

