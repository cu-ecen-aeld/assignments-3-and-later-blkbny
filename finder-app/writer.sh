#!/bin/sh
# Writer script for assignment 1
# Author: blkbny

if [ $# -ne 2 ]; then
    echo "Not enough args"
    exit 1
else
    if [ -z $1 ]; then
        echo "Not string"
        exit 1
    fi

    if [ -z $2 ]; then
        echo "Not string"
        exit 1
    fi
    writefile=$1
    writestr=$2

    mkdir -p $(dirname $writefile)

    echo "$writestr" > $writefile

    if [ $? -eq 0 ]; then
        #echo "success"
        exit 0
    else
        echo "failed"
        exit 1
    fi
fi
