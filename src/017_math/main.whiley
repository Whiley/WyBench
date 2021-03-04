import std::array

/**
 * Return the maximum value from an array of integers computed using
 * an imperative for-loop.
 */
public function max(int[] items) -> (int r)
// Cannot compute max of empty array
requires |items| > 0
// Return is element of items
ensures array::contains(items,r,0,|items|)
// Return is maximum of all
ensures all { k in 0..|items| | items[k] <= r }:
    //
    int m = items[0]
    //
    for i in 1..|items|
    // Accumulator is valid item
    where array::contains(items,m,0,i)
    // Accumulator is current max
    where all { k in 0..i | items[k] <= m }:
        if m < items[i]:
            m = items[i]
    //
    return m

/**
 * Recursive definition of what a mathematical "sum" is.  This states
 * that s is the sum of all values in items between 0 and upto (but
 * not including) i.
 *
 */ 
public property sum(int[] items,int i, int s)
where (i <= 0) ==> (s == 0)
where (i > 0) ==> sum(items,i-1, s - items[i-1])

/**
 * Compute the sum of a list of integers in an imperative style.  
 */
public function sum(int[] items) -> (int r)
// Result matches mathematical definition
ensures sum(items,|items|,r):
    r = 0
    //
    for i in 0..|items| where sum(items,i,r):
        r = r + items[i]
    //
    return r

// ===========================================================
// Tests
// ===========================================================

public method test_0():
    assert sum([]) == 0

public method test_1():
    assert max([-45]) == -45

public method test_2():
    assert sum([-45]) == -45

public method test_3():
    assert max([-33]) == -33

public method test_4():
    assert sum([-33]) == -33

public method test_5():
    assert max([-25]) == -25

public method test_6():
    assert sum([-25]) == -25

public method test_7():
    assert max([-24]) == -24

public method test_8():
    assert sum([-24]) == -24

public method test_9():
    assert max([-7]) == -7

public method test_10():
    assert sum([-7]) == -7

public method test_11():
    assert max([27]) == 27

public method test_12():
    assert sum([27]) == 27

public method test_13():
    assert max([29]) == 29

public method test_14():
    assert sum([29]) == 29

public method test_15():
    assert max([47]) == 47

public method test_16():
    assert sum([47]) == 47

public method test_17():
    assert max([84]) == 84

public method test_18():
    assert sum([84]) == 84

public method test_19():
    assert max([99]) == 99

public method test_20():
    assert sum([99]) == 99

public method test_21():
    assert max([-31, -71]) == -31

public method test_22():
    assert sum([-31, -71]) == -102

public method test_23():
    assert max([74, -52]) == 74

public method test_24():
    assert sum([74, -52]) == 22

public method test_25():
    assert max([93, -52]) == 93

public method test_26():
    assert sum([93, -52]) == 41

public method test_27():
    assert max([33, -45]) == 33

public method test_28():
    assert sum([33, -45]) == -12

public method test_29():
    assert max([0, -24]) == 0

public method test_30():
    assert sum([0, -24]) == -24

public method test_31():
    assert max([-92, 25]) == 25

public method test_32():
    assert sum([-92, 25]) == -67

public method test_33():
    assert max([-75, 31]) == 31

public method test_34():
    assert sum([-75, 31]) == -44

public method test_35():
    assert max([61, 32]) == 61

public method test_36():
    assert sum([61, 32]) == 93

public method test_37():
    assert max([51, 42]) == 51

public method test_38():
    assert sum([51, 42]) == 93

public method test_39():
    assert max([48, 96]) == 96

public method test_40():
    assert sum([48, 96]) == 144

public method test_41():
    assert max([-20, -87, -98]) == -20

public method test_42():
    assert sum([-20, -87, -98]) == -205

public method test_43():
    assert max([77, -90, -65]) == 77

public method test_44():
    assert sum([77, -90, -65]) == -78

public method test_45():
    assert max([56, 44, -22]) == 56

public method test_46():
    assert sum([56, 44, -22]) == 78

public method test_47():
    assert max([-88, -87, -14]) == -14

public method test_48():
    assert sum([-88, -87, -14]) == -189

public method test_49():
    assert max([-79, 62, -14]) == 62

public method test_50():
    assert sum([-79, 62, -14]) == -31

public method test_51():
    assert max([-79, 43, -12]) == 43

public method test_52():
    assert sum([-79, 43, -12]) == -48

public method test_53():
    assert max([-60, 13, 3]) == 13

public method test_54():
    assert sum([-60, 13, 3]) == -44

public method test_55():
    assert max([92, 64, 26]) == 92

public method test_56():
    assert sum([92, 64, 26]) == 182

public method test_57():
    assert max([28, 2, 44]) == 44

public method test_58():
    assert sum([28, 2, 44]) == 74

public method test_59():
    assert max([38, -47, 70]) == 70

public method test_60():
    assert sum([38, -47, 70]) == 61

public method test_61():
    assert max([-67, 81, -53, -55]) == 81

public method test_62():
    assert sum([-67, 81, -53, -55]) == -94

public method test_63():
    assert max([13, -100, -98, -53]) == 13

public method test_64():
    assert sum([13, -100, -98, -53]) == -238

public method test_65():
    assert max([11, 10, 79, -51]) == 79

public method test_66():
    assert sum([11, 10, 79, -51]) == 49

public method test_67():
    assert max([-10, -31, -42, -38]) == -10

public method test_68():
    assert sum([-10, -31, -42, -38]) == -121

public method test_69():
    assert max([45, -84, 84, -32]) == 84

public method test_70():
    assert sum([45, -84, 84, -32]) == 13

public method test_71():
    assert max([-75, -81, -99, -23]) == -23

public method test_72():
    assert sum([-75, -81, -99, -23]) == -278

public method test_73():
    assert max([-89, 3, -17, -4]) == 3

public method test_74():
    assert sum([-89, 3, -17, -4]) == -107

public method test_75():
    assert max([-35, 73, -22, 8]) == 73

public method test_76():
    assert sum([-35, 73, -22, 8]) == 24

public method test_77():
    assert max([24, 60, 46, 63]) == 63

public method test_78():
    assert sum([24, 60, 46, 63]) == 193

public method test_79():
    assert max([18, 99, 77, 99]) == 99

public method test_80():
    assert sum([18, 99, 77, 99]) == 293