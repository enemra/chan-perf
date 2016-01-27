#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$DATA_FILE" ]; then
    DATA_FILE="$DIR/sample.dat"
fi

stack install --executable-profiling --library-profiling

for n in 0 1 2 3 4 5 6 7
do
    chan-perf "$n" +RTS -p -hy -s < "$DATA_FILE" > /dev/null
    hp2ps -c chan-perf.hp
    cp chan-perf.ps chan-perf-"$n".ps
    open chan-perf-"$n".ps
done


