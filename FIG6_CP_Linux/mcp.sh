# multi thread cp from pmem to pmem
# dst_dir = /mnt/pmem
# pre_process_path -- xxxx_setup.sh
# ATTENTION: src should be a file
# use with bash ____.sh |tee output.txt
#          mv output.txt _______$(date +%Y%m%d%H%M%S).txt 

# set -e

if [ ! $3 ]; then
	echo Usage: $0 src dst num_job
	exit
fi

# echo Threads mcp_time\(s\)
# for ((i=1;i<=$1;i=i*2)); do
# echo -n "$i "
# bash $4 1>&2
# cd /home/cyz/nova/tools
# echo -n " "
# done
# 
size=$(du -sh "$1" --block-size=M | awk '{print $1}')
size=${size%?}

time=$(/bin/time -f %e bash -c "ulimit -n 1000000 && sudo mcp $1 $2 $3 $((2 * 1024 * 1024))" 3>&1 1>&2 2>&3)  
# echo "$time"
# bw=$((size / time))
bw=$(echo "$size/$time"|bc)
echo "$bw"
