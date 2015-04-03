package wybench

import char from whiley.lang.ASCII
import string from whiley.lang.ASCII

public type nat is (int x) where x >= 0

// ========================================================
// Parse Int
// ========================================================

public function parseInt(nat pos, string input) -> (null|int,nat):
    //
    int start = pos
    while pos < |input| && ASCII.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        return null,pos
    return Int.parse(input[start..pos]), pos

// ========================================================
// Parse Ints
// ========================================================

// Parse list of integers whilst ignoring whitespace
public function parseInts(string input) -> [int]|null:
    //    
    [int] data = []
    nat pos = skipWhiteSpace(0,input)
    // first, read data
    while pos < |input|:
        int|null i
        i,pos = parseInt(pos,input)
        if i != null:
            data = data ++ [i]
            pos = skipWhiteSpace(pos,input)
        else:
            return null
    //
    return data

// ========================================================
// Parse Real
// ========================================================

public function parseReal(nat pos, string input) -> (null|real,int):
    //
    int start = pos
    while pos < |input| && (ASCII.isDigit(input[pos]) || input[pos] == '.'):
        pos = pos + 1
    //
    if pos == start:
        return null,pos
    //
    return Real.parse(input[start..pos]),pos

// ========================================================
// Parse Reals
// ========================================================

// Parse list of reals whilst ignoring whitespace
public function parseReals(string input) -> [real]|null:
    //
    [real] data = []
    nat pos = skipWhiteSpace(0,input)
    // first, read data
    while pos < |input|:
        real|null i
        i,pos = parseReal(pos,input)
        if i != null:
            data = data ++ [i]
            pos = skipWhiteSpace(pos,input)
        else:
            return null
    //
    return data

// ========================================================
// SkipWhiteSpace
// ========================================================

public function skipWhiteSpace(nat index, string input) -> nat:
    //
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    //
    return index

// ========================================================
// IsWhiteSpace
// ========================================================

public function isWhiteSpace(char c) -> bool:
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'
