// Provide data types and functions for manipulating Huffman codes, 
// according to RFD1951.  This includes the notion of a tree for
// encoding/deciding them efficiently.

import * from whiley.lang.System
import whiley.lang.*
import Error from whiley.lang.Errors

// A code is s list of bits
define Code as [bool]

// Define the binary to hold Huffman codes
public define Leaf as {int distance, int length} | int
public define Node as {Tree one, Tree zero}
public define Tree as Leaf | Node | null

public Tree Empty():
    return null // empty tree

public Tree add(Tree tree, [bool] bits, Leaf value) throws Error:
    return add(tree, bits, value, 0)

Tree add(Tree tree, [bool] bits, Leaf value, int index) throws Error:
    if index == |bits|:
        return value
    else:
        bit = bits[index]
        if tree is Leaf:
            throw Error("invalid tree")
        else if tree is Node:
            if bit:
                tree.one = add(tree.one,bits,value,index+1)
            else:
                tree.zero = add(tree.zero,bits,value,index+1)
            return tree
        else:
            // empty tree
            if bit:
                one = add(null,bits,value,index+1)
                zero = null
            else:
                one = null
                zero = add(null,bits,value,index+1)
            return {one: one, zero: zero}

Tree get(Tree tree, bool bit) throws Error:
    if tree is Node:
        if bit:
            return tree.one
        else:
            return tree.zero
    else:
        throw Error("error")

// Generate the Huffman codes using a given sequence of code lengths.
// To understand what this method does, you really need to consult
// rfc1951.
[Code] generate([int] codeLengths):
    // (1) Count the number of codes for each code length.
    bl_count = []
    for clen in codeLengths:
        while |bl_count| <= clen:
            bl_count = bl_count + [0]
        bl_count[clen] = bl_count[clen] + 1

    // 2) Find the numerical value of the smallest code for each 
    //    code length: 
    code = 0
    bl_count[0] = 0
    next_code = [0]
    max_code = 0
    for bits in 0 .. |bl_count|:
        code = (code + bl_count[bits]) * 2        
        next_code = next_code + [code]
        max_code = Math.max(max_code,code)
    
    // 3) Assign numerical values to all codes, using consecutive 
    //    values for all codes of the same length with the base
    //    values determined at step 2. Codes that are never used  
    //    (which have a bit length of zero) must not be assigned 
    //    a value. 
    codes = []
    for n in 0 .. |codeLengths|:
        len = codeLengths[n]
        if len != 0:
            codes = codes + [next_code[len]]
            next_code[len] = next_code[len] + 1
        else:
            codes = codes + [0]
    // done
    return codes

public void ::main(System sys, [string] args):
    tree = Empty()
    try:
        tree = add(tree,[false,true],20)
        tree = add(tree,[true,false],10)
        sys.out.println(tree)
        tree = get(tree,true)
        sys.out.println(tree)
    catch(Error e):
        sys.out.println("error")
            
