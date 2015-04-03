import whiley.lang.*
import whiley.io.*
import whiley.io.File
import whiley.lang.System

import wybench.Parser

type sortedList is ([int] xs) where |xs| <= 1 || all { i in 0 .. |xs|-1 | xs[i] <= xs[i+1] }

/**
 * Sort a given list of items into ascending order, producing a sorted
 * list.
 */
function sort([int] items) -> sortedList:
    if |items| > 1:
        int pivot = |items| / 2
        [int] lhs = sort(items[..pivot])
        [int] rhs = sort(items[pivot..])
        int l, int r, int i = (0,0,0)
        while i < |items| && l < |lhs| && r < |rhs| where l >= 0 && r >= 0 && i >= 0:
            if lhs[l] <= rhs[r]:
                items[i] = lhs[l] 
                l=l+1
            else:
                items[i] = rhs[r] 
                r=r+1
            i=i+1
        while l < |lhs|:
            items[i] = lhs[l]
            i=i+1 
            l=l+1
        while r < |rhs|:
            items[i] = rhs[r] 
            i=i+1 
            r=r+1
    return items

/**
 * Perform a classical binary search on a sorted list to determine the
 * index of a given item (if it is contained) or null (otherwise).
 */
function search(sortedList list, int item) -> null|int:
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

method lookFor(System.Console console, sortedList list, int item):
    int|null index = search(list,item)
    if index != null:
        console.out.println_s("FOUND: " ++ Int.toString(item) ++ " in " ++ Any.toString(list) ++ " @ " ++ Int.toString(index))
    else:
        console.out.println_s("NOT FOUND: " ++ Int.toString(item) ++ " in " ++ Any.toString(list))

constant searchTerms is [1,2,3,4,5,6,7,8,9]

method main(System.Console sys):
    File.Reader file = File.Reader(sys.args[0])
    ASCII.string input = ASCII.fromBytes(file.readAll())
    [int] data = []
    int pos = Parser.skipWhiteSpace(0,input)
    // first, read data
    while pos < |input|:
        int|null i
        i,pos = Parser.parseInt(pos,input)
        if i != null:
            data = data ++ [i]
            pos = Parser.skipWhiteSpace(pos,input)
        else:
            sys.out.println_s("Error parsing input")
            return
    // second, sort data    
    data = sort(data)
    // third, print output
    sys.out.print_s("SORTED: " ++ Any.toString(data))
    for i in searchTerms:
        lookFor(sys,data,i)
