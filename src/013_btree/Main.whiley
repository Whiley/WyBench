import println from whiley.lang.System

// A Binary Search Tree where elements are stored in sorted order.
// That is, given a node n then we have the following invariant:
//
//   n.left.item < n.item < n.right.item, etc.
//

// =================================================
// BTree.Node
// =================================================

public define Node as {
    BTree left,
    BTree right,
    int item
} where (left == null  || left.item < item) &&
        (right == null || right.item > item)

public Node Node(int item):
    return {left: null, right: null, item: item}


public Node Node(BTree left, BTree right, int item) 
    requires (left == null  || left.item < item) && 
             (right == null || right.item > item):
    //
    return {left: left, right: right, item: item}

// =================================================
// BTree
// =================================================

public define BTree as null | Node

// Create an empty tree.
public BTree BTree():
    return null

// Add an item into the tree
public BTree add(BTree tree, int item) ensures tree == null || ($ != null && tree.item == $.item):
    if tree == null:
        return Node(item)
    else if tree.item == item:
        return tree // item alteady present
    else if tree.item < item:
        // add to right tree
        right = add(tree.right,item)
        return Node(tree.left,right,tree.item)
    else:
        // add to left tree
        left = add(tree.left,item)
        return Node(left,tree.right,tree.item)

public string toString(BTree tree):
    if tree == null:
        return "null"
    else:
        return "(" + tree.item + ", " + 
                 toString(tree.left) + ", " + 
                 toString(tree.right) + ")"

// =================================================
// Test Harness
// =================================================

define ITEMS as [54,7,201,52,3,1,0,54,12,90,9,8,8,7,34,32,35,34]

void ::main(System.Console console):
    bt = BTree()
    console.out.println(bt)
    for item in ITEMS:
        bt = add(bt,item)
        console.out.println(bt)
    
