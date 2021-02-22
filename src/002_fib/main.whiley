import std::ascii
import std::io

type nat is (int x) where x >= 0

function fib(nat x) -> nat:
    if x <= 1:
        return x
    else:
        return fib(x-1) + fib(x-2)

method test_00():
    assume fib(0) == 0

method test_01():
    assume fib(1) == 1

method test_02():
    assume fib(2) == 1

method test_03():
    assume fib(3) == 2

method test_04():
    assume fib(4) == 3

method test_05():
    assume fib(5) == 5

method test_06():
    assume fib(6) == 8

method test_07():
    assume fib(7) == 13

method test_08():
    assume fib(8) == 21

method test_09():
    assume fib(9) == 34

method test_10():
    assume fib(10) == 55

method test_11():
    assume fib(11) == 89

method test_12():
    assume fib(12) == 144
