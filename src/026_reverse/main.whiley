import std::array
import std::ascii
import std::io

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
function reverse(int[] xs) -> (int[] rs)
// Ensure that the sum of the list is preserved
ensures |xs| > 0 ==> sum(xs,0) == sum(rs,0):
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
    
function to_string(int[] items) -> ascii::string:
    ascii::string r = ""
    int i = 0
    while i < |items|:
        if i != 0:
            r = array::append(r,",")
        ascii::string str = ascii::to_string(items[0])
        r = array::append(r,str)
        i = i + 1
    //
    return r
    
method main(ascii::string[] args):
    int[] l1 = [1,2,3,4]
    int[] l2 = reverse(l1)
    io::println(array::append("L1 = ",to_string(l1)))
    io::println(array::append("L2 = ", to_string(l2)))
    io::println(array::append("SUM(L1) = ", ascii::to_string(sum(l1,0))))
    io::println(array::append("SUM(L2) = ", ascii::to_string(sum(l2,0))))
