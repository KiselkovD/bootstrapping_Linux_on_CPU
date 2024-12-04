#!/bin/bash
# Set project path to the parent directory of the script
PROJ_PATH="$(dirname "$(realpath "$0")")/.."

# start 
$PROJ_PATH/obj_dir/Vtb

echo "Exec created: obj_dir/Vtb"