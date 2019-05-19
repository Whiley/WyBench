import std::ascii
import std::array
import std::io
import std::filesystem

import wybench::parser

type sortedList is (int[] xs) 
where |xs| <= 1 || all { i in 0 .. |xs|-1 | xs[i] <= xs[i+1] }

/**
 * Sort a given list of items into ascending order, producing a sorted
 * list.
 */
function sort(int[] items, int start, int end) -> sortedList
requires start >= 0 && start < |items|
requires end >= 0 && end < |items|:
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

method lookFor(sortedList list, int item):
    int|null index = search(list,item)
    if index is int:
        io::print("FOUND: ")
        io::print(item)
        io::print(" in ")
        io::print(to_string(list))
        io::print(" @ ")
        io::println(index)
    else:
        io::print("NOT FOUND: ")
        io::print(item)
        io::print(" in ")
        io::print(list)

int[] searchTerms = [1,2,3,4,5,6,7,8,9]

method main(ascii::string[] args):
    if |args| == 0:
        io::println("usage: sort <file>")
    else:
        // first, read data
        filesystem::File file = filesystem::open(args[0],filesystem::READONLY)
        ascii::string input = ascii::from_bytes(file.read_all())
        int[]|null data = parser::parseInts(input)
        // second, sort data
        if data is int[]:
            data = sort(data,0,|data|)
            // third, print output
            io::print("SORTED: ") 
            io::println(data)
            int i = 0
            while i < |searchTerms|:
                lookFor(data,i)
                i = i + 1
        else:
            io::println("Error parsing input")

