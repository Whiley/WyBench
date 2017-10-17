/**
 * A simple implementation of the Dutch National Flag Problem.  See: 
 * 
 *  https://en.wikipedia.org/wiki/Dutch_national_flag_problem
 */
import std::ascii
import std::io

type nat is (int x) where x >= 0

// Define colours of the Dutch National Flag
int RED = 0
int WHITE = 1
int BLUE = 2

type Color is (int n) 
// The dutch national flag has three colours
where RED <= n && n <= BLUE

// Every element in given slice of array matches item.  This looks
// roughly like so:
//
//     +-+-+-+-+-+-+-+-+-+
//     | | | |i|i|i|i| | |
//     +-+-+-+-+-+-+-+-+-+
//            ^       ^
//            from    to
//
// Here, blanks are arbitrary contents and i is the item in question.
// Note how the to marker is one past the end of the matching slice.
property matches(int[] items, int from, int to, int item)
where all { i in from .. to | items[i] == item }

// Partion a randomly arranged array of the three colors (RED, WHITE,
// BLUE) into sorted order.  For example, suppose this on entry:
//
//     +-+-+-+-+-+-+-+-+-+
//     |W|B|B|W|W|B|R|R|B|
//     +-+-+-+-+-+-+-+-+-+
//
//     where |R|=2,|W|=3,|B|=4
//
// Then, the resulting array should be:
//
//     +-+-+-+-+-+-+-+-+-+
//     |R|R|W|W|W|B|B|B|B|
//     +-+-+-+-+-+-+-+-+-+
//
// The current specification for this function states that it must
// accept an array of the three colors containing at least one
// element.  Then, the result is an array of colors in sorted order.
// Note, however, that the specification currently does *not* connect the
// number of colors in the original array with that in the result.
// Therefore, the specification is currently incomplete in some sense.
function partition(Color[] cols) -> (Color[] ncols)
// Must have at least one colour in the input array
requires |cols| > 0
// Output array same size and input array
ensures |ncols| == |cols|
// Resulting array is sorted
ensures all { k in 1..|ncols| | ncols[k-1] <= ncols[k] }:
    nat lo = 0
    nat mid = 0
    int hi = |cols|
    // copy output to input
    ncols = cols 
    //
    while mid < hi
    // size of cols does not change
    where |cols| == |ncols|
    // invariants between markers
    where lo <= mid && hi <= |cols|
    // All elements up to lo are RED
    where matches(ncols,0,lo,RED)
    // All elements between lo and mid are WHITE
    where matches(ncols,lo,mid,WHITE)    
    // All elements from hi upwards are BLUE
    where matches(ncols,hi,|ncols|,BLUE):
        //
        if ncols[mid] == RED:
            ncols[mid] = ncols[lo]
            ncols[lo] = RED
            lo = lo + 1
            mid = mid + 1
        else if ncols[mid] == BLUE:
            hi = hi - 1
            ncols[mid] = ncols[hi]
            ncols[hi] = BLUE
        else:
            mid = mid + 1
    //
    return ncols

public method main(ascii::string[] args):
    int[] colors = [WHITE,RED,BLUE,WHITE]
    //
    colors = partition(colors)
    //
    io::println(colors)
