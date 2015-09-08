import whiley.lang.*

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
        return items[0] + sum_3(Array.slice(items,1,|items|))

/**
 * Compute the sum of a list of naturals 
 * (implementation 4)
 */
function sum_4(nat[] items) -> nat:
    if items == [0;0]:
        return 0
    else:
        return items[0] + sum_4(Array.slice(items,1,|items|))

// Test harness
method main(System.Console console):
    // test data
    int[] items = [90,-1,4,-54,324,-2319,-23498,23,12,93,73,56872]
    // test inc/dec 
    nat i = 0
    while i < |items|:
        if i >= 0:
            console.out.print_s("INC(DEC(")
            console.out.print_s(Int.toString(items[i]))
            console.out.print_s(")) = ")
            console.out.println_s(Int.toString(inc(dec(items[i]))))
        i = i + 1
    // test abs
    i = 0
    while i < |items|:
        console.out.print_s("ABS(")
        console.out.print_s(Int.toString(items[i]))
        console.out.print_s(") = ")
        console.out.println_s(Int.toString(abs(items[i])))
        i = i + 1
    // test max
    i = 0
    while i < |items|:
        nat j = 0
        while j < |items|:
            console.out.print_s("MAX(")
            console.out.print_s(Int.toString(items[i]))
            console.out.print_s(", ")
            console.out.print_s(Int.toString(items[j]))
            console.out.print_s(") = ")
            console.out.println_s(Int.toString(max(items[i],items[j])))
            j = j + 1
        i = i + 1
    // test min
    i = 0
    while i < |items|:
        nat j = 0
        while j < |items|:
            console.out.print_s("MIN(")
            console.out.print_s(Int.toString(items[i]))
            console.out.print_s(", ")
            console.out.print_s(Int.toString(items[j]))
            console.out.print_s(") = ")
            console.out.println_s(Int.toString(min(items[i],items[j])))
            j = j + 1
        i = i + 1
    
    // test sum_1
    items = [90,4,324,23,12,93,73,56872]
    console.out.print_s("SUM_1(")
    console.out.print_s(Any.toString(items))
    console.out.print_s(") = ")
    console.out.println_s(Int.toString(sum_1(items)))
    // test sum_2
    console.out.print_s("SUM_2(")
    console.out.print_s(Any.toString(items))
    console.out.print_s(") = ")
    console.out.println_s(Int.toString(sum_2(items)))
    // test sum_3
    console.out.print_s("SUM_3(")
    console.out.print_s(Any.toString(items))
    console.out.print_s(") = ")
    console.out.println_s(Int.toString(sum_3(items)))
    // test sum_4
    console.out.print_s("SUM_4(")
    console.out.print_s(Any.toString(items))
    console.out.print_s(") = ")
    console.out.println_s(Int.toString(sum_4(items)))
