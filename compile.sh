#!/usr/bin/env bash

# Compile nvm_tools
cd ../nvm_tools/ || exit
make -j"$(nproc)"
cd - || exit

# Compile mcp
cd ../mcp/ || exit
cmake CMakeLists.txt
make -j"$(nproc)"
if [ ! -f "/bin/mcp" ]; then
    cp ./mcp /bin/mcp    
fi
cd - || exit
