#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$DATA_FILE" ]; then
    DATA_FILE="$DIR/sample.dat"
fi

stack build --ghc-options="-eventlog"
stack install --ghc-options="-eventlog"

for n in 0 1 2 3 4 5 6 7
do
    chan-perf "$n" +RTS -l < "$DATA_FILE" > /dev/null
    ghc-events-analyze chan-perf.eventlog
    cp chan-perf.timed.svg chan-perf."$n".svg
    open chan-perf."$n".svg
done


