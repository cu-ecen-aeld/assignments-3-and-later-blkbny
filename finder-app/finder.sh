#!/bin/sh
# Finder script for assignment 1
# Author: blkbny

if [ $# -ne 2 ]; then
    echo "Not enough args"
    exit 1
else
    if [ -d $1 ]; then
        filesdir=$1
        searchstr=$2
        filenum=$(find "$filesdir" -type f | wc -l)
        linenum=$(grep -r "$searchstr" "$filesdir" | wc -l)
        echo "The number of files are ${filenum} and the number of matching lines are ${linenum}"
        exit 0
    else
        echo "Not a dir"
        exit 1

    fi
fi
