import std::ascii
import std::array
import std::io

// A Binary Search Tree where elements are stored in sorted order.
// That is, given a node n then we have the following invariant:
//
//   n.left.data < n.data < n.right.data, etc.
//

// =================================================
// Tree
// =================================================

type Tree is null | Node

type Node is ({ int data, Tree left, Tree right } n) where 
	// Data in nodes reachable from left must be below this
	(n.left is Node ==>  all { i in 0..|elts(n.left)| | elts(n.left)[i] < n.data }) &&
	// Data in nodes reachable from right must be above this
	(n.right is Node ==> all { i in 0..|elts(n.right)| | elts(n.right)[i] > n.data })

// Construct a given tree
function Node(int data, Tree left, Tree right) -> Node
// Data in nodes reachable from left must be below this
requires left is Node ==> all { i in 0..|elts(left)| | elts(left)[i] < data }
// Data in nodes reachable from right must be above this
requires right is Node ==> all { i in 0..|elts(right)| | elts(right)[i] > data }:
    //
    return {
    	data: data,
        left: left,
        right: right
    }

// Return all data elements contained in the tree
function elts(Tree t) -> (int[] ret)
// All data reachable from left node should be in result
ensures t is Node ==> all { i in 0..|elts(t.left)| | ret[i] == elts(t.left)[i] }
// Data in this node should be in result
ensures t is Node ==> t.data == ret[|elts(t.left)|]
// All data reachable from right node should be in result
ensures t is Node ==> all { i in 0..|elts(t.right)| | ret[i+|elts(t.left)|+1] == elts(t.right)[i] }:
    //
    if t is null:
        return [0;0]
    else:      
        int[] left = elts(t.left)
        int[] right = elts(t.right)
        int[] result = [0; |left| + 1 + |right|]
        result = array::copy(left,0,result,0,|left|)
        result = array::copy(right,0,result,|left|+1,|right|)
        result[|left|] = t.data
        //
        return result

// =================================================
// Insert
// =================================================

// Insert a given data element into a tree
function insert(Tree tree, int data) -> (Tree r)
// Return tree cannot be empty
ensures r is Node:
// Original tree data is retained
// ensures elts(tree) == elts(r) + {data}:
    //
    if tree is null:
        return Node(data,null,null)
    else if tree.data < data:
        // Data item is greater than this, so insert into right tree.
        Tree right = insert(tree.right, data)
        return Node(tree.data,tree.left,right)
    else if tree.data > data:
        // Data item is below this, so insert into left tree.
        Tree left = insert(tree.left, data)
        return Node(tree.data,left,tree.right)
    else:
        // Data item matches this, so do nothing
        return tree

// =================================================
// rotateClockwise
// =================================================

// Rotate a tree in the clockwise direction.  This can be used 
// to adjust reduce the height of the tree on the left-side.
//
//     Q             P
//    / \           / \
//   P   C   ==>   A   Q
//  / \               / \
// A   B             B   C
//
function rotateClockwise(Tree tree) -> (Tree r)
// All data items in the tree are preserved
ensures elts(tree) == elts(r):
    //
    if tree is null || tree.left is null:
        return tree
    else:
        //
        Tree left = tree.left
        assert left is Node
        //
        Tree right = Node(tree.data,left.right,tree.right)
        return Node(left.data,left.left,right)

// =================================================
// rotateCounterClockwise
// =================================================

// Rotate a tree in the clockwise direction.  This can be used 
// to adjust reduce the height of the tree on the left-side.
//
//     Q             P
//    / \           / \
//   P   C   <==   A   Q
//  / \               / \
// A   B             B   C
//
function rotateCounterClockwise(Tree tree) -> (Tree r)
// All data items in the tree are preserved
ensures elts(tree) == elts(r):
    //
    if tree is null || tree.right is null:
        return tree
    else:
        Tree right = tree.right
        assert right is Node
        Tree left = Node(tree.data,right.left,tree.left)
        return Node(right.data,left,right.right)

// =================================================
// toString
// =================================================

public function to_string(Tree tree) -> ascii::string:
    if tree is null:
        return "null"
    else:
        ascii::string r = "("
        r = array::append(r, ascii::to_string(tree.data))
        r = array::append(r, ", ")
        r = array::append(r, to_string(tree.left))
        r = array::append(r, ", ")
        r = array::append(r,to_string(tree.right))
        return array::append(r,")")

// =================================================
// Test Harness
// =================================================

int[] ITEMS = [54,7,201,52,3,1,0,54,12,90,9,8,8,7,34,32,35,34]

method main(ascii::string[] args):
    Tree bt = null
    Tree tmp
    //
    io::println(to_string(bt))
    //
    int i = 0
    while i < |ITEMS|:
        bt = insert(bt,ITEMS[i])
        io::println(to_string(bt))
        tmp = rotateClockwise(bt)
        io::println(to_string(tmp))
        tmp = rotateCounterClockwise(bt)
        io::println(to_string(tmp))
        i = i + 1
        
    
