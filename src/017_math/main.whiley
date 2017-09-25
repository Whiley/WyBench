import std::array
import std::ascii
import std::io

// Some simple mathematical functions

type nat is (int x) where x >= 0
type pos is (int x) where x > 0

/**
 * Increment a natural number
 */
function inc(nat x) -> pos:
    return x + 1

/**
 * Decrement a positive number
 */
function dec(pos x) -> nat:
    return x - 1

/**
 * Return absolute value of integer variable.
 */
public function abs(int x) -> (int r)
// if input positive, then result equals input
ensures x >= 0 ==> r == x
// if input negative, then result equals negated input
ensures x < 0 ==> r == -x:
    //
    if x < 0:
        return -x
    else:
        return x

/**
 * Return maximum of two integer variables
 */
public function max(int a, int b) -> (int r)
// Return cannot be smaller than either parameter
ensures r >= a && r >= b
// Return value must equal one parameter
ensures r == a || r == b:
    //
    if a < b:
        return b
    else:
        return a

/**
 * Return minimum of two integer variables
 */
public function min(int a, int b) -> (int r)
// Return cannot be greater than either parameter
ensures r <= a && r <= b
// Return value must equal one parameter
ensures r == a || r == b:
    //
    if a > b:
        return b
    else:
        return a

/**
 * Compute the sum of a list of naturals 
 * (implementation 1)
 */
function sum_1(nat[] items) -> nat:
    int r = 0
    nat i = 0
    while i < |items| where r >= 0:
        r = r + items[i]
        i = i + 1
    return r

/**
 * Compute the sum of a list of naturals 
 * (implementation 2)
 */
function sum_2(nat[] items) -> nat:
    return sum_2(items,0)

function sum_2(nat[] items, nat index) -> nat
requires index <= |items|:
    //
    if index == |items|:
        return 0
    else:
        return items[index] + sum_2(items,index+1)

/**
 * Compute the sum of a list of naturals 
 * (implementation 3)
 */
function sum_3(nat[] items) -> nat:
    if |items| == 0:
        return 0
    else:
        nat[] slice = array::slice(items,1,|items|)
        return items[0] + sum_3(slice)

/**
 * Compute the sum of a list of naturals 
 * (implementation 4)
 */
function sum_4(nat[] items) -> nat:
    if items == [0;0]:
        return 0
    else:
        nat[] slice = array::slice(items,1,|items|)
        return items[0] + sum_4(slice)

function toString(int[] items) -> ascii::string:
    ascii::string r = ""
    nat i = 0
    while i < |items|:
        if i != 0:
            r = ascii::append(r,",")
        ascii::string str = ascii::toString(items[i])
        r = ascii::append(r,str)
        i = i + 1
    //
    return r

// Test harness
method main(ascii::string[] args):
    // test data
    int[] items = [90,-1,4,-54,324,-2319,-23498,23,12,93,73,56872]
    // test inc/dec 
    nat i = 0
    while i < |items|:
        if i >= 0 && items[i] is pos:
            io::print("INC(DEC(")
            io::print(items[i])
            io::print(")) = ")
            io::println(inc(dec(items[i])))
        i = i + 1
    // test abs
    i = 0
    while i < |items|:
        io::print("ABS(")
        io::print(items[i])
        io::print(") = ")
        io::println(abs(items[i]))
        i = i + 1
    // test max
    i = 0
    while i < |items|:
        nat j = 0
        while j < |items|:
            io::print("MAX(")
            io::print(items[i])
            io::print(", ")
            io::print(items[j])
            io::print(") = ")
            io::println(max(items[i],items[j]))
            j = j + 1
        i = i + 1
    // test min
    i = 0
    while i < |items|:
        nat j = 0
        while j < |items|:
            io::print("MIN(")
            io::print(items[i])
            io::print(", ")
            io::print(items[j])
            io::print(") = ")
            io::println(min(items[i],items[j]))
            j = j + 1
        i = i + 1
    
    // test sum_1
    items = [90,4,324,23,12,93,73,56872]
    io::print("SUM_1(")
    io::print(toString(items))
    io::print(") = ")
    io::println(sum_1(items))
    // test sum_2
    io::print("SUM_2(")
    io::print(toString(items))
    io::print(") = ")
    io::println(sum_2(items))
    // test sum_3
    io::print("SUM_3(")
    io::print(toString(items))
    io::print(") = ")
    io::println(sum_3(items))
    // test sum_4
    io::print("SUM_4(")
    io::print(toString(items))
    io::print(") = ")
    io::println(sum_4(items))
