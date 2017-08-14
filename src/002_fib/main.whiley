import std::ascii
import std::io

type nat is (int x) where x >= 0

function fib(nat x) -> nat:
    if x <= 1:
        return x
    else:
        return fib(x-1) + fib(x-2)

method main(ascii::string[] args):
    nat i = 0
    while i < 41:
        nat r = fib(i)
        io::println(r)
        i = i + 1
