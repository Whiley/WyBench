import println from whiley.lang.System
import print from whiley.lang.System
import * from whiley.lang.Math
import * from whiley.lang.Real

// Some simple mathematical functions

define nat as int where $ >= 0
define pos as int where $ > 0

// Increment a natural number
pos inc(nat x):
    return x + 1

// Decrement a positive number
nat dec(pos x):
    return x - 1

// Compute the sum of a list of naturals 
// (implementation 1)
nat sum_1([nat] items):
    r = 0
    for i in items where r >= 0:
        r = r + i
    return r

// Compute the sum of a list of naturals 
// (implementation 2)
nat sum_2([nat] items):
    return sum_2(items,0)

nat sum_2([nat] items, nat index) requires index <= |items|:
    if index == |items|:
        return 0
    else:
        return items[index] + sum_2(items,index+1)

// Compute the sum of a list of naturals 
// (implementation 3)
nat sum_3([nat] items):
    if |items| == 0:
        return 0
    else:
        return items[0] + sum_3(items[1..])

// Compute the sum of a list of naturals 
// (implementation 4)
nat sum_4([nat] items):
    if items == []:
        return 0
    else:
        return items[0] + sum_4(items[1..])

string test_tan():
    res = ""
    for i in 0..8:
        res = res + "tan(PI / 4 * " + toString(i) + ") = " + toDecimal(tan(PI / 4 * i)) + "\n"
    for i in 0..12:
        res = res + "tan(PI / 6 * " + toString(i) + ") = " + toDecimal(tan(PI / 6 * i)) + "\n"
    return res

string test_sin():
    res = ""
    for i in 0..8:
        res = res + "sin(PI / 4 * " + toString(i) + ") = " + toDecimal(sin(PI / 4 * i)) + "\n"
    for i in 0..12:
        res = res + "sin(PI / 6 * " + toString(i) + ") = " + toDecimal(sin(PI / 6 * i)) + "\n"
    return res

string test_cos():
    res = ""
    for i in 0..8:
        res = res + "cos(PI / 4 * " + toString(i) + ") = " + toDecimal(cos(PI / 4 * i)) + "\n"
    for i in 0..12:
        res = res + "cos(PI / 6 * " + toString(i) + ") = " + toDecimal(cos(PI / 6 * i)) + "\n"
    return res

string test_asin():
    res = ""
    ins = [-1.0, -0.866025403, -0.707106781, -0.5, 0.0, 0.5, 0.707106781, 0.866025403]
    for r in ins:
        res = res + "asin(" + toDecimal(r) + ") = " + toDecimal(asin(r) / PI) + " * PI\n"
    return res

string test_acos():
    res = ""
    ins = [-1.0, -0.866025403, -0.707106781, -0.5, 0.0, 0.5, 0.707106781, 0.866025403]
    for r in ins:
        res = res + "acos(" + toDecimal(r) + ") = " + toDecimal(acos(r) / PI) + " * PI\n"
    return res

string test_atan():
    res = ""
    ins = [-9999999999999.0, -1.732050807, -1.0, -0.577350269, 0.0, 0.577350269, 1.0, 1.732050807, 9999999999999.0]
    for r in ins:
        res = res + "atan(" + toDecimal(r) + ") = " + toDecimal(atan(r) / PI) + " * PI\n"
    return res

string test_exp():
    res = ""
    ins = [-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0]
    for r in ins:
        res = res + "exp(" + toString(r) + ") = " + toDecimal(exp(r)) + "\n"
    return res

string test_exp10():
    res = ""
    ins = [-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0]
    for r in ins:
        res = res + "exp10(" + toString(r) + ") = " + toDecimal(exp10(r)) + "\n"
    return res

string test_log():
    res = ""
    ins = [0.135335283, 0.367879441, 0.606530659, 1.0, 1.648721270, 2.718281828, 7.389056098]
    for r in ins:
        res = res + "log(" + toDecimal(r) + ") = " + toDecimal(log(r)) + "\n"
    return res

string test_log10():
    res = ""
    ins = [0.001, 0.01, 0.1, 0.316227766, 1.0, 3.162277660, 10.0, 100.0, 1000.0]
    for r in ins:
        res = res + "log10(" + toDecimal(r) + ") = " + toDecimal(log10(r)) + "\n"
    return res

// Test harness
void ::main(System.Console console):
    // test data
    items = [90,-1,4,-54,324,-2319,-23498,23,12,93,73,56872]
    // test inc/dec 
    for i in items:
        if i >= 0:
            console.out.println("INC(DEC(" + i + ")) = " + inc(dec(i)))
    // test abs
    for i in items:
        console.out.println("ABS(" + i + ") = " + abs(i))
    // test max
    for i in items:
        for j in items:
            console.out.println("MAX(" + i + ", " + j + ") = " + max(i,j))
    // test min
    for i in items:
        for j in items:
            console.out.println("MIN(" + i + ", " + j + ") = " + min(i,j))
    
    // test sum_1
    items = [90,4,324,23,12,93,73,56872]
    console.out.println("SUM_1(" + items + ") = " + sum_1(items))
    // test sum_2
    console.out.println("SUM_2(" + items + ") = " + sum_2(items))
    // test sum_3
    console.out.println("SUM_3(" + items + ") = " + sum_3(items))
    // test sum_4
    console.out.println("SUM_3(" + items + ") = " + sum_4(items))

    // test sin, cos, tan
    console.out.print(test_tan())
    console.out.print(test_sin())
    console.out.print(test_cos())

    // test asin, acos, atan
    console.out.print(test_asin())
    console.out.print(test_acos())
    console.out.print(test_atan())

    // test exp, exp10
    console.out.print(test_exp())
    console.out.print(test_exp10())

    // test log, log10
    console.out.print(test_log())
    console.out.print(test_log10())
