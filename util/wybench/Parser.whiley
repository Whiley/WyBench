package wybench

import whiley.lang.*

public type nat is (int x) where x >= 0

// ========================================================
// Parse Ints
// ========================================================

public function parseInt(nat pos, ASCII.string input) -> (null|int val,nat npos):
    //
    int start = pos
    while pos < |input| && ASCII.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        return null,pos
    //
    return Int.parse(Array.slice(input,start,pos)), pos

// Parse list of integers whilst ignoring whitespace
public function parseInts(ASCII.string input) -> int[]|null:
    //    
    int[] data = [0;0]
    nat pos = skipWhiteSpace(0,input)
    // first, read data
    while pos < |input|:
        int|null i
        i,pos = parseInt(pos,input)
        if i is int:
            data = Array.append(data,i)
            pos = skipWhiteSpace(pos,input)
        else:
            return null
    //
    return data

// Parse lines of integers
public function parseIntLines(ASCII.string input) -> int[][]|null:
    //    
    int[][] data = [[0;0];0]
    nat pos = skipWhiteSpace(0,input)
    // first, read data
    while pos < |input|:
        int[] line = [0;0]
        while !isWhiteSpace(input[pos]):
            int|null i
            i,pos = parseInt(pos,input)
            if i is int:
                line = Array.append(line,i)
                pos = skipLineSpace(pos,input)
            else:
                return null
        //
        data = append(data,line)
        pos = skipWhiteSpace(pos,input)
    //
    return data

// Should be remove when Array.append become generic
public function append(int[][] items, int[] item) -> int[][]:
    int[][] nitems = [[0;0]; |items| + 1]
    int i = 0
    //
    while i < |items|:
        nitems[i] = items[i]
        i = i + 1
    //
    nitems[i] = item    
    //
    return nitems

// ========================================================
// Parse Strings
// ========================================================

public function parseString(nat pos, ASCII.string input) -> (ASCII.string str,nat npos):
    nat start = pos
    while pos < |input| && !isWhiteSpace(input[pos]):
        pos = pos + 1
    return Array.slice(input,start,pos),pos

// Parse list of reals whilst ignoring whitespace
public function parseStrings(ASCII.string input) -> ASCII.string[]:
    //
    ASCII.string[] data = [[0;0];0]
    nat pos = skipWhiteSpace(0,input)
    // first, read data
    while pos < |input|:
        ASCII.string s
        s,pos = parseString(pos,input)
        data = append(data,s)
        pos = skipWhiteSpace(pos,input)
    //
    return data

// ========================================================
// SkipWhiteSpace
// ========================================================

public function skipWhiteSpace(nat index, ASCII.string input) -> nat:
    //
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    //
    return index

// ========================================================
// IsWhiteSpace
// ========================================================

public function isWhiteSpace(ASCII.char c) -> bool:
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ========================================================
// SkipLineSpace
// ========================================================

public function skipLineSpace(nat index, ASCII.string input) -> nat:
    //
    while index < |input| && isLineSpace(input[index]):
        index = index + 1
    //
    return index

// ========================================================
// IsLineSpace
// ========================================================

public function isLineSpace(ASCII.char c) -> bool:
    return c == ' ' || c == '\t'
