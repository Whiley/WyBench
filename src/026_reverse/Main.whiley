import whiley.lang.*

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
    
method main(System.Console console):
    int[] l1 = [1,2,3,4]
    int[] l2 = reverse(l1)
    console.out.println_s(Array.append("L1 = ",Any.toString(l1)))
    console.out.println_s(Array.append("L2 = ", Any.toString(l2)))
    console.out.println_s(Array.append("SUM(L1) = ", Any.toString(sum(l1,0))))
    console.out.println_s(Array.append("SUM(L2) = ", Any.toString(sum(l2,0))))