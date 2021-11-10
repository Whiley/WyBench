import std::array
import std::ascii
import uint from std::integer

// Binary heap implementation.  For each node n, the key value is
// greater-or-equal than either of its children.  Furthermore, each child
// is located at located at 2n+1 and 2n+3.  For example, consider
// this heap:
//
//     Q
//    / \
//   P   C
//  / \
// A   B
//
// This would be represented in memory as follows:
//
//     +-+-+-+-+-+-+-+-+-+
//     |Q|P|C|A|B| | | | |
//     +-+-+-+-+-+-+-+-+-+
//      0 1 2 3 4 5 6 7 8 
//
// Here, the children of the root node 0 are located at 1 and 2
// respectively, whilst the children of node 1 are located at 3 and 4.
public type Heap is ({ int[] data, uint length} h)
where h.length <= |h.data|
// Items on left branch are below their parent's item
where all { i in 0..h.length | (2*i)+1 < h.length ==> h.data[i] >= h.data[(2*i)+1] }
// Items on right branch are below their parent's item
where all { i in 0..h.length | (2*i)+2 < h.length ==> h.data[i] >= h.data[(2*i)+2] }

final Heap EMPTY_HEAP = { data:[0;0], length: 0 }

// Determines whether an item is contained within the heap.
property contains(Heap h, int item)
// Some matching item exists in the heap
where some { k in 0..h.length | h.data[k] == item }

// Insert an element into the heap.  This is done by assigning the
// element to the first empty position, then swaping up the heap until
// the invariant is restored.  For example, when inserting D into out
// heap above, we begin with this state:
//
//     +-+-+-+-+-+-+-+-+-+
//     |Q|P|C|A|B|D| | | |
//     +-+-+-+-+-+-+-+-+-+
//      0 1 2 3 4 5 6 7 8 
//
// At this point, the heap invariant is broken because the key for
// node 5 (i.e. D) is greater than that of its parent (i.e. C).  To
// resolve this, we walk up the tree swapping parents down until the
// invariant is restored.  This gives the following final state:
//
//     +-+-+-+-+-+-+-+-+-+
//     |Q|P|D|A|B|C| | | |
//     +-+-+-+-+-+-+-+-+-+
//      0 1 2 3 4 5 6 7 8 
//
unsafe function push(Heap h, int item) -> (Heap r)
// Heap increased in size by one
ensures r.length == h.length + 1:
// Resulting heap contains everything from original
    // Ensure sufficient capacity
    if |h.data| == h.length:
        // Double size whilst accounting for empty array
        h.data = array::resize(h.data,(2*h.length)+1,0)
    // Save original data for preservation guarantee
    int[] data = h.data // ghost        
    // Store child position
    uint j = h.length
    // store parent position
    uint i = (j - 1) / 2    
    // Swap down to make space
    while j > 0 && data[i] < item
    // Always below length
    where i <= (h.length / 2) && i == ((j-1) / 2)
    // size of data preserved
    where |data| == |h.data|:
        // perform shift
        h.data[j] = h.data[i]
        // move child index down
        j = i
        // move parent index down
        i = (j-1) / 2        
    // Assign item into space
    h.data[j] = item
    // Increase size
    h.length = h.length + 1
    // Done
    return h

function peek(Heap heap) -> (int r)
// Heap cannot be empty
requires heap.length > 0
// Root item returns
ensures r == heap.data[0]:
    //
    return heap.data[0]

// Remove maximimal (i.e. root) item from heap.  This is done in
// essentially the opposite way to the insert.  Consider popping from
// our original example.  First, we assign the last element to the
// root position, giving this:
//
//     +-+-+-+-+-+-+-+-+-+
//     |B|P|C|A| | | | | |
//     +-+-+-+-+-+-+-+-+-+
//      0 1 2 3 4 5 6 7 8 
//
// Then, we restore the invaraint by pushing B down the heap.  This
// yields the following final state:
//
//     +-+-+-+-+-+-+-+-+-+
//     |P|B|C|A| | | | | |
//     +-+-+-+-+-+-+-+-+-+
//      0 1 2 3 4 5 6 7 8 
//
// Since P > B, we swapped them around.  At this point, we've stopped
// since B is now greater than its child (A).
unsafe function pop(Heap heap) -> (Heap r)
// Heap cannot be empty
requires heap.length > 0
// Size of heap decreased by one
ensures (heap.length - 1) == r.length
// All items except root retained
ensures all { k in 1..heap.length | contains(r,heap.data[k]) }:
    //
    int[] data = heap.data
    uint length = heap.length - 1
    // Move last element to root
    data[0] = data[length]
    // Percolate last element down to restore invariant    
    int i = 0
    // Bubble down down to make space
    while i < length:
        int item = data[i]
        int lc = (2*i)+1 // left child
        int rc = (2*i)+2 // right child
        int wc           // winning child
        //
        if lc < length && item < data[lc]:
            // bubble down left child
            wc = lc
        else if rc < length && item < data[rc]:
            // bubble down right child
            wc = rc
        else:
            // Done!
            break
        // Peform the swap
        data[i] = data[wc]
        data[wc] = item
        i = wc
    //
    return { length: length, data: data }

/**
 * Useful for debugging.
 */
public function to_string(Heap h) -> (ascii::string s):
    ascii::string r = "["
    for i in 0..h.length:
        if i > 0:
            r = array::append(r,",")
        r = array::append(r,ascii::to_string(i))
    return array::append(r,"]")

// ===================================================
// Tests
// ===================================================

public method test_01():
    Heap h = EMPTY_HEAP
    h = push(h,5)
    assume peek(h) == 5
    assert h.length == 1
    h = pop(h)
    assert h.length == 0
