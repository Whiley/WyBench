import std::array
import std::ascii

// A simple fixed-size cyclic buffer supporting read and write
// operations.

type nat is (int x) where x >= 0

type Buffer is ({
    int[] data,
    nat rpos,
    nat wpos
} b) where b.rpos < |b.data| && b.wpos < |b.data|

// Determine number of items in buffer
property size(Buffer b, int c)
where (b.rpos <= b.wpos) ==> ((b.wpos - b.rpos) == c)
where (b.rpos > b.wpos) ==> (b.wpos + (|b.data| - b.rpos)) == c

// The buffer is empty when the read and write pointers are at the
// same position.
property empty(Buffer b) where size(b,0)

// The buffer is full when the write pointer is directly before the 
// read pointer.  The special case exists where the read pointer 
// has "wrapped" around.
property full(Buffer b) where size(b,|b.data|)

// Create a buffer with a given number of slots.
function Buffer(int size) -> (Buffer buf)
// Cannot create buffer with zero size
requires size > 0
// Buffer initially empty
ensures empty(buf):
    //
    return {
        data: [0; size],
        rpos: 0,
        wpos: 0
    }

// Write an item into a buffer which is not full
function write(Buffer buf, int item) -> (Buffer nbuf)
// Cannot write into a full buffer
requires !full(buf)
// Read pointer unchanged and buffer sizes match
ensures buf.rpos == nbuf.rpos
// Correct item written
ensures nbuf.data[buf.wpos] == item
// All other items unchanged
ensures equalsExcept(buf.data,nbuf.data,buf.wpos):
    // Discard type invariant
    Buffer tmp = buf
    // Write data
    tmp.data[tmp.wpos] = item
    // Update write position
    tmp.wpos = (tmp.wpos + 1) % |tmp.data|
    //
    return tmp

// Read an item from a buffer which is not empty
function read(Buffer buf) -> (Buffer nbuf,int item)
// Cannot read from empty buffer
requires !empty(buf)
// Data is unchanged by this operation
ensures buf.data == nbuf.data
// Write pointer unchanged
ensures buf.wpos == nbuf.wpos
// Correct item returned
ensures item == buf.data[buf.rpos]:
    // Discard type invariant
    Buffer tmp = buf
    // Read data
    int val = tmp.data[buf.rpos]
    // Update read position
    tmp.rpos = (tmp.rpos + 1) % |tmp.data|
    // 
    return tmp,val

// Check that two arrays are equal, except for one item.  Should be
// deprecated by support for notation left[i:=item] == right
property equalsExcept<T>(T[] left, T[] right, nat index)
// Array sizes are identical
where |left| == |right|
// All items except that at index are identical
where all { k in 0..|left| | k == index || left[k] == right[k] }

function toString(Buffer b) -> ascii::string:
    ascii::string r = "["
    int i = 0
    while i < |b.data|
    where 0 <= i && i <= |b.data|:
        if i != 0:
            r = array::append(r,", ")
        if i == b.rpos:
            r = array::append(r,"<")
        if i == b.wpos:
            r = array::append(r,">")
        r = array::append(r,ascii::to_string(b.data[i]))
        i = i + 1
    return array::append(r,"]")

// ===============================================
// Tests
// ===============================================

unsafe public method test_01():
    int v
    Buffer b = Buffer(5)
    // Write an element
    b = write(b,1)
    // Buffer is not full
    assert !full(b)
    // Read out of buffer
    (b,v) = read(b)
    // Check element
    assert v == 1
    // Check buffer empty
    assert empty(b)
    
