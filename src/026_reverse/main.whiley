import std::array
import std::ascii

// Sum over the elements of a list
function sum(int[] xs, int index) -> (int r)
requires index >= 0 && index <= |xs|
// Base case: list of size 0
ensures index == |xs| ==> r == 0
// General case: list of size greater than 1
ensures index < |xs| ==> r == xs[index] + sum(xs,index+1):
    //
    if index == |xs|:
        return 0
    else:
        return xs[index] + sum(xs,index+1)
        
// Reverse the elements of a list
unsafe function reverse(int[] xs) -> (int[] rs)
// Ensure that the sum of the list is preserved
ensures (|xs| > 0) ==> (sum(xs,0) == sum(rs,0)):
    //
    int i = 0
    int j = |xs|
    int[] ys = xs
    //
    while i < j 
        // ensure size of xs unchanged
        where i >= 0 && j <= |xs| && |xs| == |ys|
        // ensure invariant maintained by loop
        where |xs| > 0 ==> sum(xs,0) == sum(ys,0):
        // do the swap
        j = j - 1
        ys[i] = xs[j]
        ys[j] = xs[i]
        i = i + 1        
    //
    return ys

// =======================================================
// Tests
// =======================================================

public method test_01():
    assume reverse([]) == []

public method test_02():
    assume reverse([1]) == [1]

public method test_03():
    assume reverse([1,2]) == [2,1]

public method test_04():
    assume reverse([1,2,3]) == [3,2,1]

