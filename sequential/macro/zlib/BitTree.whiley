import * from whiley.lang.System
import whiley.lang.*
import Error from whiley.lang.Errors

public define BitPair as {int distance, int length}
public define BitLeaf as BitPair | int
public define BitNode as {BitTree one, BitTree zero}
public define BitTree as BitLeaf | BitNode | null

public BitTree Empty():
    return null // empty tree

public BitTree add(BitTree tree, [bool] bits, BitLeaf value) throws Error:
    return add(tree, bits, value, 0)

BitTree add(BitTree tree, [bool] bits, BitLeaf value, int index) throws Error:
    if index == |bits|:
        return value
    else:
        bit = bits[index]
        if tree is BitLeaf:
            throw Error("invalid tree")
        else if tree is BitNode:
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

BitTree get(BitTree tree, bool bit) throws Error:
    if tree is BitNode:
        if bit:
            return tree.one
        else:
            return tree.zero
    else:
        throw Error("error")

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
            
