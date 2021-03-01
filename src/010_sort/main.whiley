import std::ascii
import std::array

property sorted(int[] xs, int start, int end) 
where start >= end || all { i in start .. (end-1) | xs[i] <= xs[i+1] }

type sorted is (int[] xs) where sorted(xs,0,|xs|)

/**
 * Sort a given list of items into ascending order, producing a sorted
 * list.
 */
function sort(int[] items) -> (sorted rs):
    return sort(items,0,|items|)

function sort(int[] items, int start, int end) -> (sorted rs)
requires 0 <= start && start <= end && end <= |items|:
    //
    if (start+1) < end:
        int pivot = (end + start) / 2
        int[] lhs = sort(items,start,pivot)
        int[] rhs = sort(items,pivot,end)
        int l = start
        int r = pivot
        int i = start
        while i < end && l < pivot && r < end where l >= 0 && r >= 0 && i >= 0:
            if lhs[l] <= rhs[r]:
                items[i] = lhs[l] 
                l=l+1
            else:
                items[i] = rhs[r] 
                r=r+1
            i=i+1
        while l < pivot:
            items[i] = lhs[l]
            i=i+1 
            l=l+1
        while r < end:
            items[i] = rhs[r] 
            i=i+1 
            r=r+1
    //
    return (sorted) items

/**
 * Perform a classical binary search on a sorted list to determine the
 * index of a given item (if it is contained) or null (otherwise).
 */
function search(sorted list, int item) -> null|int:
    int lower = 0
    int upper = |list| // 1 past last element considered
    while lower < upper:
        int pivot = (lower + upper) / 2
        int candidate = list[pivot]
        if candidate == item:
            return pivot
        else if candidate < item:
            lower = pivot + 1
        else:
            upper = pivot
    // failed to find it
    return null

// ============================================
// Tests
// ============================================

public method test_01():
    sorted items = sort([])
    assume items == []
    assume search(items,-1) == null
    assume search(items,0) == null
    assume search(items,1) == null
    assume search(items,2) == null

public method test_02():
    sorted items = sort([0])
    assume items == [0]
    assume search(items,-1) == null
    assume search(items,0) == 0
    assume search(items,1) == null
    assume search(items,2) == null

public method test_03():
    sorted items = sort([1,0])
    assume items == [0,1]
    assume search(items,-1) == null
    assume search(items,0) == 0
    assume search(items,1) == 1
    assume search(items,2) == null
