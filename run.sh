#!/bin/sh

NRUNS=10
NRAMPUPS=5

LIBDIR=$WHILEY_HOME/lib

# check for running under cywin
cygwin=false
case "`uname`" in
  CYGWIN*) cygwin=true ;;
esac

##################
# RUN APPLICATION
##################

if $cygwin; then
    # under cygwin the classpath separator must be ";"
    LIBDIR=`cygpath -pw "$LIBDIR"`
    WHILEY_CLASSPATH=".;$LIBDIR/wyrt.jar"
    SEP=";"
else
    # under UNIX the classpath separator must be ":"
    WHILEY_CLASSPATH=".:$LIBDIR/wyrt.jar"
    SEP=":"
fi


#sequential_micro="gcd fib matrix queens regex sorter codejam_0511A codejam_0511B"

sequential_micro="gcd fib queens regex sorter codejam_0511A codejam_0511B scc"
input_file="small.in"

for benchmark in $sequential_micro
do
    echo $benchmark
    echo "================================================"
    echo -n "Java:   "
    java -server -cp "${WHILEY_CLASSPATH}${SEP}sequential/micro/$benchmark" Runner -r$NRAMPUPS -n$NRUNS JavaMain sequential/micro/$benchmark/$input_file
    echo -n "Whiley: "
    java -server -cp "${WHILEY_CLASSPATH}${SEP}sequential/micro/$benchmark" Runner -r$NRAMPUPS -n$NRUNS Main sequential/micro/$benchmark/$input_file
    echo ""
done
