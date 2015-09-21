import whiley.lang.System

constant RED is 0
constant WHITE is 1
constant BLUE is 2

type Color is (int n) 
// The dutch national flag has three colours
where n == RED || n == WHITE || n == BLUE 

function partition(Color[] cols) -> (Color[] r):
    int lo = 0
    int mid = 0
    int hi = |cols|-1

    while mid <= hi
        where lo >= 0 && lo <= mid && hi < |cols|:
        //
        if cols[mid] < WHITE:
            cols = swap(cols,lo,mid)
            lo = lo + 1
            mid = mid + 1
        else if cols[mid] > WHITE:
            cols = swap(cols,mid,hi)
            hi = hi - 1
        else:
            mid = mid + 1
    //
    return cols

function swap(Color[] cols, int i, int j) -> (Color[] r)
// Requires that index i is within bounds
requires i >= 0 && i < |cols|
// Requires that index j is within bounds
requires j >= 0 && j < |cols|:
    //
    int tmp = cols[i]
    cols[i] = cols[j]
    cols[j] = tmp
    return cols

public method main(System.Console console):
    int[] colors = [WHITE,RED,BLUE,WHITE]
    //
    colors = partition(colors)
    //
    console.out.println(colors)