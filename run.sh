#!/bin/sh

NRUNS=10
NRAMPUPS=5

#sequential_micro="gcd fib matrix queens regex sorter codejam_0511A codejam_0511B"

sequential_micro="gcd fib queens regex sorter codejam_0511A codejam_0511B"

for benchmark in $sequential_micro
do
    echo $benchmark
    echo "================================================"
    echo -n "Java:   "
    java -server -cp ".:$WHILEY_HOME/lib/wyrt.jar:sequential/micro/$benchmark" Runner -r$NRAMPUPS -n$NRUNS JavaMain sequential/micro/$benchmark/small.in
    echo -n "Whiley: "
    java -server -cp ".:$WHILEY_HOME/lib/wyrt.jar:sequential/micro/$benchmark" Runner -r$NRAMPUPS -n$NRUNS Main sequential/micro/$benchmark/small.in
    echo ""
done