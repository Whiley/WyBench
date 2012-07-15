// Copyright (c) 2011, David J. Pearce
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name of the <organization> nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------
package zlib.core

// Provide data types and functions for manipulating Huffman codes, 
// according to RFD1951.  This includes the notion of a tree for
// encoding/deciding them efficiently.

import * from whiley.lang.System
import whiley.lang.*
import Error from whiley.lang.Errors

// A code is s list of bits
define Code as [bool]

// Define the binary to hold Huffman codes
public define Literal as int
public define Node as {Tree one, Tree zero}
public define Tree as Literal | Node | null

public Tree Empty():
    return null // empty tree

// Map a given code to a given value
public Tree put(Tree tree, Code code, Literal value) throws Error:
    return put(tree, code, value, |code|)

// helper
Tree put(Tree tree, [bool] bits, Literal value, int index) throws Error:
    if index == 0:
        if tree == null:
            return value
        else:
            throw Error("invalid tree (1)")
    else:
        index = index - 1
        bit = bits[index]
        if tree is Literal:
            throw Error("invalid tree (2)")
        else if tree is Node:
            if bit:
                tree.one = put(tree.one,bits,value,index)
            else:
                tree.zero = put(tree.zero,bits,value,index)
            return tree
        else:
            // empty tree
            if bit:
                one = put(null,bits,value,index)
                zero = null
            else:
                one = null
                zero = put(null,bits,value,index)
            return {one: one, zero: zero}

Tree get(Tree tree, bool bit) throws Error:
    if tree is Node:
        if bit:
            return tree.one
        else:
            return tree.zero
    else:
        throw Error("error")

// return the number of code,symbol mappings
public int size(Tree tree):
    if tree == null:
        return 0
    else if tree is Literal:
        return 1
    else:
        // tree is Node
        return size(tree.one) + size(tree.zero)
    
// Generate the Huffman codes using a given sequence of code lengths.
// To understand what this method does, you really need to consult
// rfc1951.
[Code|null] generate([int] codeLengths):
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
    for bits in 0 .. |bl_count|:
        code = (code + bl_count[bits]) * 2        
        next_code = next_code + [code]
    // 3) Assign numerical values to all codes, using consecutive 
    //    values for all codes of the same length with the base
    //    values determined at step 2. Codes that are never used  
    //    (which have a bit length of zero) must not be assigned 
    //    a value. 
    codes = []
    for n in 0 .. |codeLengths|:
        len = codeLengths[n]
        if len != 0:
            code = construct(next_code[len],len)
            codes = codes + [code]
            next_code[len] = next_code[len] + 1
        else:
            codes = codes + [null]
    // done
    return codes

// convert an integer into a code value of a given length.
Code construct(int code, int len):
    r = []
    for i in 0 .. len:
        if (code % 2) == 1:
            r = r + [true]
        else:
            r = r + [false]
        code = code / 2
    return r

public void ::main(System.Console sys):
    //codes = generate([2,1,3,3])
    codes = generate([3,3,3,3,3,2,4,4])
    // first, print generated codes
    for i in 0..|codes|:
        sys.out.print(i + " : ")
        code = codes[i]
        if code == null:
            sys.out.println("")
        else:
            for j in |code| .. 0:
                if code[j-1]:
                    sys.out.print("1")
                else:
                    sys.out.print("0")
            sys.out.println("")
    // second, construct corresponding binary tree
    try:
        tree = Empty()
        for i in 0..|codes|:
            code = codes[i]
            if code != null:
                tree = put(tree,code,i)
        sys.out.println(tree)
    catch(Error e):
         sys.out.println("error")
            
