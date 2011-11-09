#!/bin/sh

NRUNS=5
NRAMPUPS=2

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

sequential_micro="gcd fib queens regex sorter codejam_0511A scc"
input_file="small.in"

echo -e "#\tJava\t\t\tWhiley"
echo "#================================================"

for benchmark in $sequential_micro
do
    echo -n -e "$benchmark\t"
    java -server -cp "${WHILEY_CLASSPATH}${SEP}sequential/micro/$benchmark" Runner -r$NRAMPUPS -n$NRUNS JavaMain sequential/micro/$benchmark/$input_file
    echo -n -e "\t"
    java -server -cp "${WHILEY_CLASSPATH}${SEP}sequential/micro/$benchmark" Runner -r$NRAMPUPS -n$NRUNS Main sequential/micro/$benchmark/$input_file
    echo ""
done
