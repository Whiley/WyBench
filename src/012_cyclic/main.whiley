import std::array
import std::ascii
import std::io

// A simple fixed-size cyclic buffer supporting read and write
// operations.

type nat is (int x) where x >= 0

type Buffer is ({
    int[] data,
    nat rpos,
    nat wpos
} b) where b.rpos < |b.data| && b.wpos < |b.data|

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
function Buffer(int size) -> EmptyBuffer
// Cannot create buffer with zero size
requires size > 0:
    //
    return {
        data: [0; size],
        rpos: 0,
        wpos: 0
    }

// Write an item into a buffer which is not full
function write(NonFullBuffer buf, int item) -> (Buffer nbuf)
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
function read(NonEmptyBuffer buf) -> (Buffer nbuf,int item)
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

function isFull(Buffer buf) -> (bool r)
ensures buf is FullBuffer ==> r:
    //
    return (buf.rpos == buf.wpos + 1) || 
            (buf.wpos == |buf.data|-1 && buf.rpos == 0)

function isEmpty(Buffer buf) -> (bool r)
ensures buf is EmptyBuffer ==> r :
    //
    return buf.rpos == buf.wpos

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

int[] ITEMS = [5,4,6,3,7,2,8,1,9,10,0]

public method main(ascii::string[] args):
    int i = 0
    Buffer buf = Buffer(10)
    //
    io::print("INIT: ")
    io::println(toString(buf))
    
    // NOTE: following loop invariant should not be necessary!  It is
    // needed because the verifier doesn't current enforce the
    // variables declared invariants.
    while i < |ITEMS| 
        where i >= 0
        where buf.rpos >= 0 && buf.rpos < |buf.data|
        where buf.wpos >= 0 && buf.wpos < |buf.data|:
        //
        if isFull(buf):
            io::println("BUFFER FULL")
            break
        buf = write(buf,ITEMS[i])
        io::print("WROTE: ")
        io::print(ITEMS[i])
        io::print(", ")
        io::println(toString(buf))
        i = i + 1
    //
    int item
    i = 0
    //
    // NOTE: following loop invariant should not be necessary!  It is
    // needed because the verifier doesn't current enforce the
    // variables declared invariants.
    while i < |ITEMS| 
        where i >= 0
        where buf.rpos >= 0 && buf.rpos < |buf.data|
        where buf.wpos >= 0 && buf.wpos < |buf.data|:
        //
        if isEmpty(buf):
            io::println("BUFFER EMPTY")
            break
        buf,item = read(buf)
        if item == ITEMS[i]:
            io::print("READ: ")
            io::print(item) 
            io::print(", ")
            io::println(toString(buf))
        else:
            io::print("ERROR READ: ")
            io::print(item)
            io::print(", expecting ")
            io::println(ITEMS[i])
        i = i + 1
    
