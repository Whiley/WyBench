#!/bin/bash

files=$(ls -d ???_*)

for f in $files
do
    echo "Building $f"
    cd $f
    rm -rf bin ; wy build
    cd ..
done
