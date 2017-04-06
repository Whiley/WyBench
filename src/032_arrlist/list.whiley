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
// Has valid next link, or "null" pointer
where (n.next < l.size) || (n.next == |l.links|)

type LinkedList is ({Link[] links, nat size} l)
// Never more links than available space
where l.size <= |l.links|
// All links are valid
where all { i in 0..l.size | valid(l,l.links[i],i) }

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
// Index either "null" or within used portion of list
requires (i < list.size) || (i == |list.links|):
    //
    Link[] ls = list.links
    ls[list.size] = Link(data,i)
    return { links: ls, size: list.size+1 }
