// Sum over the elements of a list
function sum([int] xs) -> (int r)
requires |xs| > 0
// Base case: list of size 1
ensures |xs| == 1 ==> r == xs[0]
// General case: list of size greater than 1
ensures |xs| > 1 ==> r == xs[0] + sum(xs[1..]):
    //
    if |xs| == 1:
        return xs[0]
    else:
        return xs[0] + sum(xs[1..])
        
// Reverse the elements of a list
function reverse([int] xs) -> ([int] rs)
// Ensure that the sum of the list is preserved
ensures |xs| > 0 ==> sum(xs) == sum(rs):
    //
    int i = 0
    int j = |xs|
    [int] ys = xs
    //
    while i < j 
        // ensure size of xs unchanged
        where i >= 0 && j <= |xs| && |xs| == |ys|
        // ensure invariant maintained by loop
        where |xs| > 0 ==> sum(xs) == sum(ys):
        // do the swap
        j = j - 1
        ys[i] = xs[j]
        ys[j] = xs[i]
        i = i + 1        
    //
    return ys
    
method main(System.Console console):
    [int] l1 = [1,2,3,4]
    [int] l2 = reverse(l1)
    console.out.println_s("L1 = " ++ Any.toString(l1))
    console.out.println_s("L2 = " ++ Any.toString(l2))
    console.out.println_s("SUM(L1) = " ++ Any.toString(sum(l1)))
    console.out.println_s("SUM(L2) = " ++ Any.toString(sum(l2)))