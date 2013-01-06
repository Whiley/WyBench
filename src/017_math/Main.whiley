import println from whiley.lang.System

// Some simple mathematical functions

define nat as int where $ >= 0
define pos as int where $ > 0

// Increment a natural number
pos inc(nat x):
    return x + 1

// Decrement a positive number
nat dec(pos x):
    return x - 1

// Compute the absolute of an integer
nat abs(int x):
    if x < 0:
        return -x
    else:
        return x

// Compute the max of two integers
int max(int x, int y) 
    ensures ($ >= x && $ >= y) && ($ == x || $ == y):
    //
    if x > y:
        return x
    else:
        return y

// Compute the min of two integers
int min(int x, int y) 
    ensures ($ <= x && $ <= y) && ($ == x || $ == y):
    //
    if x < y:
        return x
    else:
        return y

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
    if items == []:
        return 0
    else:
        return items[0] + sum_3(items[1..])

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

    
    
