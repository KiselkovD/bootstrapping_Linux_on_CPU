#!/bin/bash
# Set project path to the parent directory of the script
PROJ_PATH="$(dirname "$(realpath "$0")")/.."

# Compile 
verilator --binary "$PROJ_PATH/src/test.sv" "$PROJ_PATH/src/tb.sv" --top tb

# Check if the compilation was successful
#if [ $? -ne 0 ]; then
#    echo "Compilation failed."
#    exit 1
#fi

echo "Exec created: obj_dir/Vtb"