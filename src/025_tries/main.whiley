import std::ascii
import std::array
import nat from std::integer
import std::io
import std::math

// A straightforward implementation of a "trie".  This is a directed
// acyclic graph structure which encodes multiple strings in a compact
// fashion.  As a simplest example, the string "abc" is encoded like so:
//
// (0) -- a --> (1) -- b --> (2) -- c --> (3)
//
// Since this only encodes one string, there is no real benefit.
// Support we now add the string "abd" to the trie.  Then, the structure
// would look like this:
//
// (0) -- a --> (1) -- b --> (2) -- c --> (3)
//                             \
//                              \-- d --> (4)
//
// Finally, suppose we add the string "ace", then the structure looks
// like this:
//
//                 /-- c --> (5) -- e --> (6)
//                /          
// (0) -- a --> (1) -- b --> (2) -- c --> (3)
//                             \
//                              \-- d --> (4)
//
// Finally, observe the given representation of tries is, in some
// sense, "lossy".  This is because there is no mechanism to determine
// exactly which states represent "end points".  Thus, we must assume
// that any state represents an end point.  Therefore, the string "ab"
// is considered to be contained in the above structure, even though we
// didn't actually put it in.

// Represents a transition from one state to another for a given character.
type Transition is {
    nat from,
    nat to,
    ascii::char character
} where from < to

// Define the Empty Transition
Transition EMPTY_TRANSITION = { from: 0, to: 1, character: 'a' }

property valid(Transition t, nat size)
where t.from < size && t.to < size

// A Finite State Machine representation of a Trie
type Trie is {
    nat size, // maximum number of states
    Transition[] transitions
} where size > 0
// Ensures each transition to/from state within trie
where all { k in 0..|transitions| | valid(transitions[k],size) }

// Define the Empty Trie, which always has root state 0
Trie EMPTY_TRIE = { size: 1, transitions: [EMPTY_TRANSITION; 0] }

// Add a complete string into a Trie starting from the root node.
function add(Trie trie, ascii::string str) -> Trie:
    return add(trie,0,str,0)

// Add a string into a Trie from a given state, producing an 
// updated Trie.
function add(Trie trie, nat state, ascii::string str, nat index) -> Trie
// Require valid state within trie and valid index within string
requires state < trie.size && index <= |str|:
    //
    if index == |str|:
        return trie
    else:
        //
        // Check whether transition exists for first 
        // character of str already.
        ascii::char c = str[index]
        int i = 0
        //
        while i < |trie.transitions| where i >= 0:
            Transition t = trie.transitions[i]
            if t.from == state && t.character == c:
                // Yes, existing transition for chaeracter
                return add(trie,t.to,str,index+1)
            i = i + 1
        // No existing transition, so make a new one.
        nat target = trie.size
        Transition t = { from: state, to: target, character: c }
        trie = add(trie,t)
        //
        return add(trie,target,str,index+1)

// Add a new transition to the trie.  This function should be
// deprecate when it becomes easier to reuse one of the existing Array
// functions.
function add(Trie trie, Transition transition) -> (Trie r)
// One more transition added
ensures |r.transitions| == |trie.transitions| + 1
// Everything is unchanged upto the new transition
ensures array::equals(trie.transitions,r.transitions,0,|trie.transitions|)
// New transition correctly added
ensures r.transitions[|trie.transitions|] == transition
// Size greater than new transition nodes
ensures r.size > transition.from && r.size > transition.to
// Size can only increase
ensures r.size >= trie.size:
    // append new transition
    Transition[] rs = array::append(trie.transitions,transition)
    // compute updated size
    nat max = (nat) math::max(trie.size,transition.from+1)
    max = (nat) math::max(max,transition.to+1)
    // done
    return { size: max, transitions: rs }

// Check whether a given string is contained in the trie, 
// starting from the root state.
function contains(Trie trie, ascii::string str) -> bool:        
    return contains(trie,0,str,0)

// Check whether a given string is contained in the trie, 
// starting from a given state.
function contains(Trie trie, int state, ascii::string str, nat index) -> bool
requires index <= |str|
requires state >= 0:
    //
    if index == |str|:
        return true
    else:
        // Check whether transition exists for first 
        // character of str.
        ascii::char c = str[index]
        int i = 0
        //
        while i < |trie.transitions| where i >= 0:
            Transition t = trie.transitions[i]
            if t.from == state && t.character == c:
                // Yes, existing transition for character
                return contains(trie,t.to,str,index+1)
            i = i + 1
        //
        return false

// =======================================================
// Tests
// =======================================================

public method test_01():
    Trie t = EMPTY_TRIE
    assume !contains(t,"hello")

public method test_02():
    Trie t = EMPTY_TRIE
    // add something
    t = add(t,"hello")
    // check its there
    assume contains(t,"hello")
    // check something else not there
    assume !contains(t,"world")

public method test_03():
    Trie t = EMPTY_TRIE
    // add something
    t = add(t,"hello")
    // check its there
    assume contains(t,"hello")
    // add something else
    t = add(t,"world")
    // check both there
    assume contains(t,"hello")
    assume contains(t,"world")
