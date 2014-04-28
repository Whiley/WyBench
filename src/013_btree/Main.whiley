import println from whiley.lang.System

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
function Node(int data, Tree left, Tree right) => Node
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
function elts(Tree t) => ({int} ret)
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
function insert(Tree tree, int data) => (Tree r)
// Return tree cannot be empty
ensures r != null
// Original tree data is retained
ensures elts(tree) == elts(r) + {data}:
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

public function toString(Tree tree) => string:
    if tree == null:
        return "null"
    else:
        return "(" ++ tree.data ++ ", " ++
                 toString(tree.left) ++ ", " ++
                 toString(tree.right) ++ ")"

// =================================================
// Test Harness
// =================================================

constant ITEMS is [54,7,201,52,3,1,0,54,12,90,9,8,8,7,34,32,35,34]

method main(System.Console console):
    Tree bt = null
    console.out.println(bt)
    for item in ITEMS:
        bt = insert(bt,item)
        console.out.println(bt)
    
