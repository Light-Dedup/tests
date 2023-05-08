#!/usr/bin/env bash

#!/usr/bin/env bash

loop=1
if [ "$1" ]; then
    loop=$1
fi

./test-cp.sh "$loop"
./test-trace.sh "$loop"