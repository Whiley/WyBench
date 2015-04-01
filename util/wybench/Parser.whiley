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
