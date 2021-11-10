// Based on a tutorial from the Verification Corner.  See this:
//
// http://www.youtube.com/watch?v=P2durYFsJSA
//

import std::array
import std::ascii
import uint from std::integer

/**
 * Convert a bit sequence into a integer in the usual manner.  
 * For example:
 *
 * 001 ==> 1
 * 010 ==> 2
 * 011 ==> 3
 * 100 ==> 4
 * ...
 *
 * Note that we're assuming unsigned sequences here only, and also
 * that bit 0 occupies index 0.
 */
function value(bool[] bits) -> (uint result):
    //
    return value(0,1,bits)

function value(uint k, uint pow, bool[] bits) -> (uint result):
    if k >= |bits|:
        return 0
    else if(bits[k]):
        return pow + value(k+1,pow*2,bits)
    else:
        return value(k+1,pow*2,bits)

/**
 * Return n^k
 */
function pow(uint n, uint k) -> (uint r):
    if k == 0:
        return 1
    else:
        return n * pow(n,k-1)

/**
 * Bitwise increment.  This changes the first false 
 * bit to true, and all prior bits to false.  If no 
 * such bit exists, true is added to the end.
 *
 * For example:
 *
 * 011 ==> 100 
 * 101 ==> 110
 *
 * (writing most significant bit first)
 */
unsafe function increment(bool[] bits) -> (bool[] result, bool carry)
// Result has same dimension
ensures |result| == |bits|
// If no carry, result incremented in place
ensures !carry ==> (value(result) == value(bits) + 1)
// Otherwise, result requires carry
ensures carry ==> (value(result) + pow(2,|bits|) == value(bits) + 1):
    //
    uint i = 0
    //
    while i < |bits| && bits[i] == true:
       //
       bits[i] = false
       i = i + 1
    //
    if i < |bits|:
        bits[i] = true
        return (bits,false)
    else:
        return (bits,true)

// ============================================================
// Tests (value)
// ============================================================

public export method test_01():
    assume value([false]) == 0

public export method test_02():
    assume value([true]) == 1

public export method test_03():
    assume value([false,false]) == 0

public export method test_04():
    assume value([true,false]) == 1

public export method test_05():
    assume value([false,true]) == 2

public export method test_06():
    assume value([true,true]) == 3

// ============================================================
// Tests (increment)
// ============================================================

public export method test_07():
    assume increment([false]) == ([true],false)

public export method test_08():
    assume increment([true]) == ([false],true)

public export method test_09():
    assume increment([false,true]) == ([true,true],false)

public export method test_10():
    assume increment([true,true]) == ([false,false],true)
