import whiley.lang.*
import whiley.lang.System:*

int fib(int x):
    if x <= 1:
        return 1
    else:
        return fib(x-1) + fib(x-2)

void ::main(System sys, [string] args):
    for i in 1 .. 41:
        r = fib(i)
        sys.out.println(String.str(r))
