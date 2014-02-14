import println from whiley.lang.System

// A simple fixed-size cyclic buffer supporting read and write
// operations.

type nat is (int x) where x >= 0

type Buffer is {
    [int] data,
    nat rpos,
    nat wpos
} where rpos < |data| && wpos < |data|

// The buffer is empty when the read and write pointers are at the
// same position.
type EmptyBuffer is (Buffer b) where b.rpos == b.wpos

// The buffer is non-empty when the read and write pointers are at
// different positions.
type NonEmptyBuffer is (Buffer b) where b.rpos != b.wpos

// The buffer is full when the write pointer is directly before the 
// read pointer.  The special case exists where the read pointer 
// has "wrapped" around.
type FullBuffer is (Buffer b) where (b.rpos == b.wpos + 1) || (b.wpos == |b.data|-1 && b.rpos == 0)

// NonFullBuffer has at least one writeable space.  Invariant obtained
// by applying DeMorgan's Theorem to the invariant for a full buffer.
type NonFullBuffer is (Buffer b) where (b.rpos != b.wpos + 1) && (b.wpos != |b.data|-1 || b.rpos != 0)

// Create a buffer with a given number of slots.
public function Buffer(int size) => EmptyBuffer
// Cannot create buffer with zero size
requires size > 0:
    //
    [int] data = []
    int i = 0
    while i < size:
        data = data ++ [0]
        i = i + 1
    assume |data| == size
    return {
        data: data,
        rpos: 0,
        wpos: 0
    }

// Write an item into a buffer which is not full
public function write(NonFullBuffer buf, int item) => Buffer:
    //
    buf.data[buf.wpos] = item
    buf.wpos = buf.wpos + 1
    // NOTE: could use modulus operator here
    if buf.wpos >= |buf.data|:
        buf.wpos = 0
    return buf

// Read an item from a buffer which is not empty
public function read(NonEmptyBuffer buf) => (Buffer,int):
    int item = buf.data[buf.rpos]
    buf.rpos = buf.rpos + 1
    // NOTE: could use modulus operator here
    if buf.rpos >= |buf.data|:
        buf.rpos = 0
    return (buf,item)

public function isFull(Buffer buf) => bool:
    return (buf.rpos == buf.wpos + 1) || 
            (buf.wpos == |buf.data|-1 && buf.rpos == 0)

public function isEmpty(Buffer buf) => bool:
    return buf.rpos == buf.wpos

public function toString(Buffer b) => string:
    string r = "["
    for i in 0..|b.data|:
        if i != 0:
            r = r ++ ", "
        if i == b.rpos:
            r = r ++ "<"
        if i == b.wpos:
            r = r ++ ">"
        r = r ++ b.data[i]
    return r ++ "]"

constant ITEMS is [5,4,6,3,7,2,8,1,9,10,0]

method main(System.Console console):
    int i
    Buffer buf = Buffer(10)
    //
    console.out.println("INIT: " ++ toString(buf))
    for item in ITEMS:
        if isFull(buf):
            console.out.println("BUFFER FULL")
            break
        buf = write(buf,item)
        console.out.println("WROTE: " ++ item ++ ", " ++ toString(buf))
    for item in ITEMS:
        if isEmpty(buf):
            console.out.println("BUFFER EMPTY")
            break
        buf,i = read(buf)
        if i == item:
            console.out.println("READ: " ++ i ++ ", " ++ toString(buf))
        else:
            console.out.println("ERROR: read " ++ i ++ ", expecting " ++ item)
    