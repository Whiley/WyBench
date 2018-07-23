import std::ascii

// An "array based" link-list implementation
type nat is (int x) where x >= 0

type Link is {
    int data,
    nat next  // index of next node in list
}

function Link(int d, nat n) -> (Link r)
ensures (r.data == d) && (r.next == n):
    return { data: d, next: n }

property valid(LinkedList l, Link n, int i)
// All next links go "down", cannot be cyclic or a "null"
where (n.next < i) || (i == 0) || (n.next == |l.links|)

type LinkedList is ({Link[] links, nat size} l)
// Never more links than available space
where l.size <= |l.links|
// All links are valid
where all { i in 0 .. l.size | valid(l,l.links[i],i) }

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

function toString(Link l) -> (ascii::string s):
    ascii::string r = "{"
    r = ascii::append(r,ascii::toString(l.data))
    r = ascii::append(r,";")        
    r = ascii::append(r,ascii::toString(l.next))    
    return ascii::append(r,"}")

function toString(LinkedList l) -> (ascii::string s):
    int i = 0
    ascii::string r = "["
    while i < |l.links|:
        r = ascii::append(r,toString(l.links[i]))
        i = i + 1
    //
    return ascii::append(r,"]")

public export method main():
    LinkedList l1 = {links: [], size: 0}
    ascii::string r = toString(l1)
    debug "GOT HERE"