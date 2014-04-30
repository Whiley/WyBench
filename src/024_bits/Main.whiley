// Based on a tutorial from the Verification Corner.  See this:
//
// http://www.youtube.com/watch?v=P2durYFsJSA
//


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
 * Note that we're assuming unsigned sequences here only.
 */

function value([bool] bits) => (int result)
// We are only consider unsigned integers
ensures result >= 0:
    //
    int i = 0
    int r = 0
    int acc = 1
    //
    while i < |bits| where i >= 0 && r >= 0 && acc >= 1:
        if bits[i]:
            r = r + acc
        i = i + 1
        acc = acc + acc
    //
    return r

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
function increment([bool] bits) => ([bool] result)
// This is the key property for this benchmark
ensures value(result) == value(bits) + 1:
    //
    int i = 0
    //
    while i < |bits| && bits[i] == true 
       where i >= 0:
       //
       bits[i] = false
       i = i + 1
    //
    if i < |bits|:
        bits[i] = true
        return bits
    else:
        return bits ++ [true]

/**
 * Print out a sequence of bits in the usual 
 * right-to-left format.
 */
function toString([bool] bits, int n) => string:
    int i = 0
    string r = ""
    //
    while i < n where i >= 0:
       if i < |bits| && bits[i]:
           r = "1" ++ r
       else:
           r = "0" ++ r
       i = i + 1
    //
    return r
 
method main(System.Console console):
    [bool] bits = [ false ]
    int i = 0
    //
    while i < 16:
        console.out.println(toString(bits,4) ++ " = " ++ value(bits))
        bits = increment(bits)
        i = i + 1
    //