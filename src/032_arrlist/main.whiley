import std::array

// An "array based" link-list implementation
type nat is (int x) where x >= 0

type Link is {
    int data,
    nat next  // index of next node in list
}

function Link(int d, nat n) -> (Link r)
ensures (r.data == d) && (r.next == n):
    return { data: d, next: n }

property valid(RawLinkedList l, Link n, int i)
// All next links go "down", cannot be cyclic or a "null"
where (n.next < i) || (i == 0 && n.next == |l.links|) || (n.next == |l.links|)

// NOTE: need to break infinite loop between valid() and LinkedList
// below.
type RawLinkedList is ({Link[] links, nat size} l)

type LinkedList is ({Link[] links, nat size} l)
// Never more links than available space
where l.size <= |l.links|
// All links are valid
where all { i in 0 .. l.size | valid(l,l.links[i],i) }

// Construct a linked list with a maximum number of nodes
function LinkedList(nat max) -> (LinkedList e)
// Ensure have exactly the given number of links
ensures |e.links| == max
// Initial size always zero
ensures e.size == 0:
  // 
  final Link DUMMY = { data: 0, next: 0 }
  // Create the empty list
  return {links: [DUMMY;max], size: 0}

// Determine the length of a list from a given index
function length(LinkedList list, nat i) -> (nat r)
// Index either "null" or within used portion of list
requires (i < list.size) || (i == |list.links|):
    //
    if i == |list.links|:
        // null terminator
        return 0
    else:
        Link ith = list.links[i]
        return 1 + length(list,ith.next)

function insert(LinkedList list, nat i, int data) -> (LinkedList r)
// Must be space to insert the new link
requires list.size < |list.links|
// Index either "null" or within used portion of list
requires (i < list.size) || (i == |list.links|):
    //
    Link[] ls = list.links
    ls[list.size] = Link(data,i)
    return { links: ls, size: list.size+1 }


// =======================================================
// Tests
// =======================================================

public method test_01():
    LinkedList l1 = LinkedList(5)
    assert l1.size == 0

public method test_02():
    LinkedList l1 = LinkedList(5)
    LinkedList l2 = insert(l1,5,0)
    assert l1.size == 1
