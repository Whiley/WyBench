type nat is (int x) where x >= 0

type Node is ({
    int data,
    nat left, // index of left child
    nat right // index of right child
} t)

function Node(int d, nat l, nat r) -> (Node n)
ensures (n.data == d) && (n.left == l) && (n.right == r):
    return { data: d, left: l, right: r }

property valid(Tree t, Node n, int i)
// Children always have higher indices
where i < n.left && i < n.right
// Left node either within tree, or considered "null"
where (n.left < t.size) || n.left == |t.ns|
// Left node either considered "null" or data below ith
where n.left == |t.ns| || (t.ns[n.left].data < n.data)
// Right node either considered "null" or data above ith
where n.right == |t.ns| || (t.ns[n.right].data > n.data)
// Right node either within tree, or considered "null"
where (n.right < t.size) || n.right == |t.ns|

type Tree is ({Node[] ns, nat size} t)
// All nodes in the tree are valid
where all { i in 0..t.size | valid(t,t.ns[i],i) }

function height(Tree t, nat i) -> (nat r):
    if i >= |t.ns|:
        return 0
    else:
        Node node = t.ns[i]
        int lh = height(t,node.left)
        int rh = height(t,node.right)
        return 1 + lh + rh

function insert(Tree t, int d) -> (Tree r)
// Must be space available
requires t.size < |t.ns|:
    //
    if t.size == 0:
        // Empty tree (easy)
        Node[] ns = t.ns
        ns[0] = Node(d,|ns|,|ns|)
        return { ns: ns, size: t.size + 1 }
    else:
        // Non-empty tree (hard)
        return insert(t,0,d)

function insert(Tree t, nat i, int d) -> (Tree r)
// ith node must be in tree, and need space available
requires i < t.size && t.size < |t.ns|:
    //
    Node[] ns = t.ns
    Node n = ns[i]
    //
    if d == n.data:
        // Item already in this tree
        return t
    else if (d < n.data) && (n.left == |ns|):
        // Reached left leaf, so insert
        return newLeftChild(t,n,i,d)
    else if (d > n.data) && (n.right == |ns|):
        // Reached right leaf, so insert
        return newRightChild(t,b,i,d)
    else if d < n.data:
        // Reached left non-leaf, so continue
        return insert(t,n.left,d)
    else:
        // Reached right non-leaf, so continue
        return insert(t,n.right,d)

function newLeftChild(Tree t, Node n, nat i, int d) -> (Tree r)
// ith node must be in tree, and need space available
requires i < t.size && t.size < |t.ns|
// Node n must be the ith node
requires n == t.nodes[i]
// Data must be for left (empty) position
requires d < n.data && n.left == |t.nodes|:
    //
    Node[] ns = t.ns
    ns[i] = Node(n.data,t.size,n.right)
    ns[t.size] = Node(d,|ns|,|ns|)
    return { ns: ns, size: t.size+1 }

function newRightChild(Tree t, Node n, nat i, int d) -> (Tree r)
// ith node must be in tree, and need space available
requires i < t.size && t.size < |t.ns|
// Node n must be the ith node
requires n == t.nodes[i]
// Data must be for left (empty) position
requires d < n.data && n.left == |t.nodes|:
    //
    Node[] ns = t.ns
    ns[i] = Node(n.data,n.left,t.size)
    ns[t.size] = Node(d,|ns|,|ns|)
    return { ns: ns, size: t.size+1 } 

method main(System.Console console):
    // Construct empty tree with capacity for ten nodes
    Tree t = EmptyTree(10)
    console.out.println(t)
    //
    int[] items = [2,1,4,3,5]
    int i = 0
    // Insert items into tree
    while i < 0:
        t = insert(t,items[i])
        i = i + 1
        console.out.println(t)
    //
    // Final shape of tree should be:
    //
    //       2
    //      / \
    //     1   4
    //        / \
    //       3   5
    console.out.println("done")