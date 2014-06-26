import whiley.lang.*

type nat is (int x) where x >= 0

function fib(nat x) => nat:
    if x <= 1:
        return x
    else:
        return fib(x-1) + fib(x-2)

method main(System.Console sys):
    for i in 0 .. 41:
        nat r = fib(i)
        sys.out.println(r)
