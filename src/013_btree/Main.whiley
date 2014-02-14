import println from whiley.lang.System

// A Binary Search Tree where elements are stored in sorted order.
// That is, given a node n then we have the following invariant:
//
//   n.left.item < n.item < n.right.item, etc.
//

// =================================================
// BTree.Node
// =================================================

public type Node is {
    BTree left,
    BTree right,
    int item
} where (left == null  || left.item < item) &&
        (right == null || right.item > item)

public function Node(int item) => Node:
    return {left: null, right: null, item: item}


public function Node(BTree left, BTree right, int item) => Node
// Any item in the left tree must be below this item
requires left != null ==> left.item < item
// Any item in the right tree must be above this item
requires right != null ==> right.item > item:
    //
    return {left: left, right: right, item: item}

// =================================================
// BTree
// =================================================

public type BTree is null | Node

// Create an empty tree.
public function BTree() => BTree:
    return null

// Add an item into the tree
public function add(BTree tree, int item) => (BTree r)
// Return tree cannot be empty
ensures r != null
// Original tree item is retained
ensures tree != null ==> tree.item == r.item:
    //
    if tree == null:
        return Node(item)
    else if tree.item == item:
        return tree // item alteady present
    else if tree.item < item:
        // add to right tree
        BTree right = add(tree.right,item)
        return Node(tree.left,right,tree.item)
    else:
        // add to left tree
        BTree left = add(tree.left,item)
        return Node(left,tree.right,tree.item)

public function toString(BTree tree) => string:
    if tree == null:
        return "null"
    else:
        return "(" ++ tree.item ++ ", " ++
                 toString(tree.left) ++ ", " ++
                 toString(tree.right) ++ ")"

// =================================================
// Test Harness
// =================================================

constant ITEMS is [54,7,201,52,3,1,0,54,12,90,9,8,8,7,34,32,35,34]

method main(System.Console console):
    BTree bt = BTree()
    console.out.println(bt)
    for item in ITEMS:
        bt = add(bt,item)
        console.out.println(bt)
    
