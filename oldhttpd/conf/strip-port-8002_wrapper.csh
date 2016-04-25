#!/bin/csh
set file="$1"
#
set dest="$2"

echo "file:"$file
echo "dest :"$dest 

./strip-port-8002 $file > $dest
