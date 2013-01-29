import println from whiley.lang.System

// A simple fixed-size cyclic buffer supporting read and write
// operations.

define nat as int where $ >= 0

define Buffer as {
    [int] data,
    nat rpos,
    nat wpos
} where rpos < |data| && wpos < |data|

// The buffer is empty when the read and write pointers are at the
// same position.
define EmptyBuffer as Buffer where $.rpos == $.wpos

// The buffer is non-empty when the read and write pointers are at
// different positions.
define NonEmptyBuffer as Buffer where $.rpos != $.wpos

// The buffer is full when the write pointer is directly before the 
// read pointer.  The special case exists where the read pointer 
// has "wrapped" around.
define FullBuffer as Buffer where ($.rpos == $.wpos + 1) || ($.wpos == |$.data|-1 && $.rpos == 0)

// NonFullBuffer has at least one writeable space.  Invariant obtained
// by applying DeMorgan's Theorem to the invariant for a full buffer.
define NonFullBuffer as Buffer where ($.rpos != $.wpos + 1) && ($.wpos != |$.data|-1 || $.rpos != 0)

// Create a buffer with a given number of slots.
public EmptyBuffer Buffer(int size) requires size > 0:
    data = []
    i = 0
    while i < size:
        data = data + [0]
        i = i + 1
    assume |data| == size
    return {
        data: data,
        rpos: 0,
        wpos: 0
    }

// Write an item into a buffer which is not full
public Buffer write(NonFullBuffer buf, int item):
    buf.data[buf.wpos] = item
    buf.wpos = buf.wpos + 1
    // NOTE: could use modulus operator here
    if buf.wpos >= |buf.data|:
        buf.wpos = 0
    return buf

// Read an item from a buffer which is not empty
public (Buffer,int) read(NonEmptyBuffer buf):
    item = buf.data[buf.rpos]
    buf.rpos = buf.rpos + 1
    // NOTE: could use modulus operator here
    if buf.rpos >= |buf.data|:
        buf.rpos = 0
    return (buf,item)

public bool isFull(Buffer buf):
    return (buf.rpos == buf.wpos + 1) || 
            (buf.wpos == |buf.data|-1 && buf.rpos == 0)

public bool isEmpty(Buffer buf):
    return buf.rpos == buf.wpos

public string toString(Buffer b):
    r = "["
    for i in 0..|b.data|:
        if i != 0:
            r = r + ", "
        if i == b.rpos:
            r = r + "<"
        if i == b.wpos:
            r = r + ">"
        r = r + b.data[i]
    return r + "]"

define ITEMS as [5,4,6,3,7,2,8,1,9,10,0]

void ::main(System.Console console):
    buf = Buffer(10)
    console.out.println("INIT: " + toString(buf))
    for item in ITEMS:
        if isFull(buf):
            console.out.println("BUFFER FULL")
            break
        buf = write(buf,item)
        console.out.println("WROTE: " + item + ", " + toString(buf))
    for item in ITEMS:
        if isEmpty(buf):
            console.out.println("BUFFER EMPTY")
            break
        buf,i = read(buf)
        if i == item:
            console.out.println("READ: " + i + ", " + toString(buf))
        else:
            console.out.println("ERROR: read " + i + ", expecting " + item)
    