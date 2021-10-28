// This example is taken from the VerifyThis'19 Competition.
//
// Given a sequence s, the monotonic cutpoints are any indices which
// cut s into segments that are monotonic: each segment's elements are
// either all increasing or all decreasing.  For example:
//
// s = [1,2,3,4,5,7],         cuts = [0,6]
// s = [1,4,7,3,3,5,9],   cuts = [0,3,5,7] (i.e. 1,4,7 | 3,3 | 5,9 )
// s = [6,3,4,2,5,3,7], cuts = [0,2,3,6,7] (i.e. 6,3 | 4,2 | 5,3 | 7 )
//
// This challenge focuses on maximal cut points.  That is, we cannot
// extend any segment further.
import uint from std::integer

property non_empty(int[] seq)
where |seq| > 0

property begin_to_end(int[] seq, int b, int e)
where seq[0] == b && seq[|seq|-1] == e

property within_bounds(int[] seq, int n)
where all { k in 0..|seq| | 0 <= seq[k] && seq[k] <= n }

// =================================================================
// find cut points
// =================================================================

function findCutPoints(int[] s) -> (int[] c)
// Verification task 1
ensures non_empty(c) && begin_to_end(c,0,|s|) && within_bounds(c,|s|):
    final uint n = |s|
    int[] cut = [0]
    uint x = 0
    uint y = 1
    //
    while y < n
    where x < y && x <= n
    where non_empty(cut) && begin_to_end(cut,0,x) && within_bounds(cut,x):
        bool increasing = (s[x] < s[y])
        //
        while y < n && (s[y-1] < s[y] <==> increasing)
        where x < y && y <= n:
            y = y + 1
        //
        cut = append(cut, y)
        x = y
        y = x + 1
    //
    if x < n:
        cut = append(cut, n)
    //
    return cut

// =================================================================
// append
// =================================================================

// NOTE: its frustrating we cannot use array::append here.

public function append(int[] items, int item) -> (int[] r)
// Every item from original array is retained
ensures all { k in 0..|items| | r[k] == items[k] }
// Last item in result matches item appended
ensures r[|items|] == item
// Size of array is one larger than original
ensures |r| == |items|+1:
    //
    int[] nitems = [item; |items| + 1]
    //
    for i in 0..|items|
    where |nitems| == |items|+1
    where nitems[|items|] == item
    where all { k in 0..i | nitems[k] == items[k] }:
        nitems[i] = items[i]
    //
    return nitems


// =================================================================
// Tests
// =================================================================

public method test_01():
    int[] s = [1,2,3,4,5,7]
    assume findCutPoints(s) == [0,6]

public method test_02():
    int[] s = [1,4,7,3,3,5,9]
    assume findCutPoints(s) == [0,3,5,7]

public method test_03():
    int[] s = [6,3,4,2,5,3,7]
    assume findCutPoints(s) == [0,2,4,6,7]