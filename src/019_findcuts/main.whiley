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
type uint is (int x) where x >= 0

property non_empty(int[] seq)
where |seq| > 0

property begin_to_end(int[] seq, int b, int e)
where seq[0] == b && seq[|seq|-1] == e

property within_bounds(int[] seq, int n)
where all { k in 0..|seq| | 0 <= seq[k] && seq[k] <= n }

// Sequence [start..end) is monotonically increasing.
property increasing(int[] seq, int start, int end)
where all { i in start .. end, j in start .. end | i < j ==> seq[i] < seq[j] }

// Sequence [start..end) is monotonically decreasing.
property decreasing(int[] seq, int start, int end)
where all { i in start .. end, j in start .. end | i < j ==> seq[i] >= seq[j] }

// Monotonic property of a single segment
property monotonic(int[] seq, int start, int end)
where increasing(seq,start,end) || decreasing(seq,start,end)

// Monotonic property for a set of cutpoints
property monotonic(int[] seq, int[] cut)
// Cut sequence itself be increasing
where increasing(cut,0,|cut|)
//
where all { k in 1 .. |cut| | monotonic(seq,cut[k-1],cut[k]) }

// =================================================================
// find cut points
// =================================================================

function findCutPoints(int[] s) -> (int[] c)
// Verification task 1
ensures non_empty(c) && begin_to_end(c,0,|s|) && within_bounds(c,|s|)
// Verification task 2
ensures monotonic(s,c):
    final uint n = |s|
    int[] cut = [0]
    uint x = 0
    uint y = 1
    //
    while y < n
    where y == (x + 1) && x <= n
    // Verification task 1
    where non_empty(cut) && begin_to_end(cut,0,x) && within_bounds(cut,x)
    // Verification task 2
    where monotonic(s,cut):
        //bool inc = (s[x] < s[y])
        int p = y // ghost
        //
        while y < n && (s[y-1] < s[y]) //&& (s[y-1] < s[y] <==> inc)
        where x < y && y <= n
        // Verification task 2
        where increasing(s,p,y):
            y = y + 1
        // Extend the cut
        cut = extend(s,cut,p,y)
        x = y
        y = x + 1
    //
    if x < n:
        cut = extend(s, cut, x+1, n)
    //
    return cut

// =================================================================
// Extend
// =================================================================

unsafe function extend(int[] seq, int[] cut, int start, int end) -> (int[] ncut)
// New segment must follow from last
requires begin_to_end(cut,0,start-1)
// Incoming cut must be monotonic
requires monotonic(seq,cut)
// Segment being added must be monotonic
requires monotonic(seq,start,end)
// Every item from original array is retained
ensures all { k in 0..|cut| | ncut[k] == cut[k] }
// Ensure property
ensures begin_to_end(ncut,0,end)
// Ensure respond is monotonic
ensures monotonic(seq,ncut):
    //
    int[] nc = [end; |cut| + 1]
    //
    for i in 0..|cut|
    where |nc| == |cut|+1
    where nc[|cut|] == end
    where all { k in 0..i | nc[k] == cut[k] }:
        nc[i] = cut[i]
    //
    return nc


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