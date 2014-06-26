// Some simple mathematical functions

type nat is (int x) where x >= 0
type pos is (int x) where x > 0

/**
 * Increment a natural number
 */
function inc(nat x) => pos:
    return x + 1

/**
 * Decrement a positive number
 */
function dec(pos x) => nat:
    return x - 1

/**
 * Return absolute value of integer variable.
 */
public function abs(int x) => (int r)
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
public function max(int a, int b) => (int r)
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
public function min(int a, int b) => (int r)
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
function sum_1([nat] items) => nat:
    int r = 0
    for i in items where r >= 0:
        r = r + i
    return r

/**
 * Compute the sum of a list of naturals 
 * (implementation 2)
 */
function sum_2([nat] items) => nat:
    return sum_2a(items,0)

function sum_2([nat] items, nat index) => nat
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
function sum_3([nat] items) => nat:
    if |items| == 0:
        return 0
    else:
        return items[0] + sum_3(items[1..])

/**
 * Compute the sum of a list of naturals 
 * (implementation 4)
 */
function sum_4([nat] items) => nat:
    if items == []:
        return 0
    else:
        return items[0] + sum_4(items[1..])

// Test harness
method main(System.Console console):
    // test data
    [int] items = [90,-1,4,-54,324,-2319,-23498,23,12,93,73,56872]
    // test inc/dec 
    for i in items:
        if i >= 0:
            console.out.println("INC(DEC(" ++ i ++ ")) = " ++ inc(dec(i)))
    // test abs
    for i in items:
        console.out.println("ABS(" ++ i ++ ") = " ++ abs(i))
    // test max
    for i in items:
        for j in items:
            console.out.println("MAX(" ++ i ++ ", " ++ j ++ ") = " ++ max(i,j))
    // test min
    for i in items:
        for j in items:
            console.out.println("MIN(" ++ i ++ ", " ++ j ++ ") = " ++ min(i,j))
    
    // test sum_1
    items = [90,4,324,23,12,93,73,56872]
    console.out.println("SUM_1(" ++ items ++ ") = " ++ sum_1(items))
    // test sum_2
    console.out.println("SUM_2(" ++ items ++ ") = " ++ sum_2(items))
    // test sum_3
    console.out.println("SUM_3(" ++ items ++ ") = " ++ sum_3(items))
    // test sum_4
    console.out.println("SUM_3(" ++ items ++ ") = " ++ sum_4(items))
