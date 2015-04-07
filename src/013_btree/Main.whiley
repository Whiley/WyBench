import whiley.lang.System
import whiley.lang.Int
import string from whiley.lang.ASCII

// A Binary Search Tree where elements are stored in sorted order.
// That is, given a node n then we have the following invariant:
//
//   n.left.data < n.data < n.right.data, etc.
//

// =================================================
// Tree
// =================================================

type Tree is null | Node

type Node is { int data, Tree left, Tree right } where 
	// Data in nodes reachable from left must be below this
	(left != null ==> all { d in elts(left) | d < data }) &&
	// Data in nodes reachable from right must be above this
	(right != null ==> all { d in elts(right) | d > data })

// Construct a given tree
function Node(int data, Tree left, Tree right) -> Node
// Data in nodes reachable from left must be below this
requires left != null ==> all { d in elts(left) | d < data }
// Data in nodes reachable from right must be above this
requires right != null ==> all { d in elts(right) | d > data }:
    //
    return {
    	data: data,
        left: left,
        right: right
    }

// Return all data elements contained in the tree
function elts(Tree t) -> ({int} ret)
// Data in this node should be in result
ensures t != null ==> t.data in ret
// All data reachable from left node should be in result
ensures t != null ==> elts(t.left) ⊆ ret
// All data reachable from right node should be in result
ensures t != null ==> elts(t.right) ⊆ ret:
    //
    if t is null:
        return {}
    else:        
        return elts(t.left) + {t.data} + elts(t.right)

// =================================================
// Insert
// =================================================

// Insert a given data element into a tree
function insert(Tree tree, int data) -> (Tree r)
// Return tree cannot be empty
ensures r != null:
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
    if tree == null:
        return tree
    //
    Tree left = tree.left 
    //
    if left == null:
        return tree
    else:
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
    if tree == null:
        return tree
    //
    Tree right = tree.right
    //
    if right == null:
        return tree
    else:
        Tree left = Node(tree.data,right.left,tree.left)
        return Node(right.data,left,right.right)

// =================================================
// toString
// =================================================

public function toString(Tree tree) -> string:
    if tree == null:
        return "null"
    else:
        return "(" ++ Int.toString(tree.data) ++ ", " ++
                 toString(tree.left) ++ ", " ++
                 toString(tree.right) ++ ")"

// =================================================
// Test Harness
// =================================================

constant ITEMS is [54,7,201,52,3,1,0,54,12,90,9,8,8,7,34,32,35,34]

method main(System.Console console):
    Tree bt = null
    Tree tmp
    //
    console.out.println(bt)
    //
    for item in ITEMS:
        bt = insert(bt,item)
        console.out.println(bt)
        tmp = rotateClockwise(bt)
        console.out.println(tmp)
        tmp = rotateCounterClockwise(bt)
        console.out.println(tmp)
        
    
