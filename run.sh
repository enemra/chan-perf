#!/usr/bin/env bash

set -e

stack install --executable-profiling --library-profiling

for n in 0 1 2 3 4 5
do
    chan-perf "$n" +RTS -p -hy -s < "$DATA_FILE" > /dev/null
    hp2ps -c chan-perf.hp
    cp chan-perf.ps chan-perf-"$n".ps
    open chan-perf-"$n".ps
done


