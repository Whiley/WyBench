import whiley.lang.*
import * from whiley.lang.System

int fib(int x):
    if x <= 1:
        return 1
    else:
        return fib(x-1) + fib(x-2)

void ::main(System.Console sys):
    for i in 1 .. 41:
        r = fib(i)
        sys.out.println(r)
