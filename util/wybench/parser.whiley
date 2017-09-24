package wybench

import std::array
import std::ascii

public type nat is (int x) where x >= 0

// ========================================================
// Parse Ints
// ========================================================

public function parseInt(nat pos, ascii::string input) -> (null|int val,nat npos)
requires pos <= |input|:
    //
    nat start = pos
    while pos < |input| && ascii::isDigit(input[pos])
    where start <= pos && pos <= |input|:
        pos = pos + 1
    if pos == start:
        return null,pos
    //
    ascii::string slice = array::slice(input,start,pos)
    return ascii::parseInt(slice), pos

// Parse list of integers whilst ignoring whitespace
public function parseInts(ascii::string input) -> int[]|null:
    //    
    int[] data = [0;0]
    nat pos = skipWhiteSpace(0,input)
    // first, read data
    while pos < |input|:
        int|null i
        i,pos = parseInt(pos,input)
        if i is int:
            data = array::append(data,i)
            pos = skipWhiteSpace(pos,input)
        else:
            return null
    //
    return data

// Parse lines of integers
public function parseIntLines(ascii::string input) -> int[][]|null:
    //    
    int[][] data = [[0;0];0]
    nat pos = skipWhiteSpace(0,input)
    // first, read data
    while pos < |input|:
        int[] line = [0;0]
        while pos < |input| && !isWhiteSpace(input[pos]):
            int|null i
            i,pos = parseInt(pos,input)
            if i is int:
                line = array::append(line,i)
                pos = skipLineSpace(pos,input)
            else:
                return null
        //
        data = append(data,line)
        pos = skipWhiteSpace(pos,input)
    //
    return data

// Should be remove when array::append become generic
public function append(int[][] items, int[] item) -> (int[][] r)
ensures |r| == |items| + 1
ensures all { k in 0..|items| | r[k] == items[k] }
ensures r[|items|] == item:
    //
    int[][] nitems = [[0;0]; |items| + 1]
    nat i = 0
    //
    while i < |items|
    where |nitems| == |items| + 1 && i <= |items|
    where all { k in 0..i | nitems[k] == items[k] }:
        nitems[i] = items[i]
        i = i + 1
    //
    nitems[i] = item    
    //
    return nitems

// ========================================================
// Parse Strings
// ========================================================

public function parseString(nat pos, ascii::string input) -> (ascii::string str,nat npos)
requires pos <= |input|:
    nat start = pos
    while pos < |input| && !isWhiteSpace(input[pos])
    where start <= pos && pos <= |input|:
        pos = pos + 1
    //
    return array::slice(input,start,pos),pos

// Parse list of reals whilst ignoring whitespace
public function parseStrings(ascii::string input) -> ascii::string[]:
    //
    ascii::string[] data = [[0;0];0]
    nat pos = skipWhiteSpace(0,input)
    // first, read data
    while pos < |input|:
        ascii::string s
        s,pos = parseString(pos,input)
        data = append(data,s)
        pos = skipWhiteSpace(pos,input)
    //
    return data

// ========================================================
// SkipWhiteSpace
// ========================================================

public function skipWhiteSpace(nat index, ascii::string input) -> nat:
    //
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    //
    return index

// ========================================================
// IsWhiteSpace
// ========================================================

public function isWhiteSpace(ascii::char c) -> bool:
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ========================================================
// SkipLineSpace
// ========================================================

public function skipLineSpace(nat index, ascii::string input) -> nat:
    //
    while index < |input| && isLineSpace(input[index]):
        index = index + 1
    //
    return index

// ========================================================
// IsLineSpace
// ========================================================

public function isLineSpace(ascii::char c) -> bool:
    return c == ' ' || c == '\t'
