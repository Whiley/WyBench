import whiley.io.*
import * from whiley.io.File
import whiley.lang.*
import * from whiley.lang.System
import * from whiley.lang.Errors

type sortedList is ([int] xs) where |xs| <= 1 || all { i in 0 .. |xs|-1 | xs[i] <= xs[i+1] }

/**
 * Sort a given list of items into ascending order, producing a sorted
 * list.
 */
function sort([int] items) => sortedList:
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
function search(sortedList list, int item) => null|int:
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

/**
 * Parse an integer from a given string starting at a given point,
 * returning a pair consisting of the integer and the first position
 * following it in the string.
 */
function parseInt(int pos, string input) => (int,int) 
throws SyntaxError:
    //
    int start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    return Int.parse(input[start..pos]),pos

/**
 * Skip past any whitespace in the given string starting from the given
 * position, returning the position of the next non-whitespace character.
 */
function skipWhiteSpace(int index, string input) => int:
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

/**
 * Check whether a given character is a whitespace character or not.
 */
function isWhiteSpace(char c) => bool:
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

method lookFor(System.Console console, sortedList list, int item):
    int|null index = search(list,item)
    if index != null:
        console.out.println("FOUND: " ++ item ++ " in " ++ list ++ " @ " ++ index)
    else:
        console.out.println("NOT FOUND: " ++ item ++ " in " ++ list)

constant searchTerms is [1,2,3,4,5,6,7,8,9]

method main(System.Console sys):
    File.Reader file = File.Reader(sys.args[0])
    string input = String.fromASCII(file.readAll())
    try:
        [int] data = []
        int pos = skipWhiteSpace(0,input)
        // first, read data
        while pos < |input|:
            int i
            i,pos = parseInt(pos,input)
            data = data ++ [i]
            pos = skipWhiteSpace(pos,input)
        // second, sort data    
        data = sort(data)
        // third, print output
        sys.out.print("SORTED: " ++ Any.toString(data))
        for i in searchTerms:
            lookFor(sys,data,i)
    catch(SyntaxError e):
        sys.out.println("Syntax error: " ++ e.msg)
