#!/usr/bin/env bash

set -e

stack install --executable-profiling --library-profiling

for n in 0 1 2 3 4 5
do
    skylark-perf "$n" +RTS -p -hy -s < "$DATA_FILE" > /dev/null
    hp2ps -c skylark-perf.hp
    cp skylark-perf.ps skylark-perf-"$n".ps
    open skylark-perf-"$n".ps
done


