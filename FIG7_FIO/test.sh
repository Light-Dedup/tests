#!/usr/bin/env bash

#!/usr/bin/env bash

loop=1
if [ "$1" ]; then
    loop=$1
fi

./test-4K.sh "$loop"
./test-continuous.sh "$loop"