type nat is (int x) where x >= 0

function gcd(nat a, nat b) -> nat
requires a != 0 && b != 0:
    //
    while(b != 0) where a >= 0:
        if(a > b):
            a = a - b
        else:
            b = b - a
    return a

public method test_01():
    assume gcd(1,1) == 1

public method test_02():
    assume gcd(4,2) == 2

public method test_03():
    assume gcd(2,4) == 2

public method test_04():
    assume gcd(2,3) == 1

public method test_05():
    assume gcd(3,9) == 3

public method test_06():
    assume gcd(9,30) == 3

public method test_07():
    assume gcd(25,30) == 5

public method test_08():
    assume gcd(14,35) == 7
