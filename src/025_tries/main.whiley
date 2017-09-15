import std::ascii
import nat from std::integer
import std::io

// Represents a transition from one 
// state to another for a given character.
type Transition is ({
    int from,
    int to,
    ascii::char character
} tr) where 
    tr.from >= 0 && tr.to >= 0 &&
    tr.from < tr.to

// Define the Empty Transition
Transition EmptyTransition = { from: 0, to: 0, character: 'a' }

// A Finite State Machine representation of a Trie
type Trie is {
    Transition[] transitions
} 

// Define the Empty Trie
Trie EmptyTrie = { transitions: [EmptyTransition; 0] }

// Add a complete string into a Trie starting from the root node.
function add(Trie trie, ascii::string str) -> Trie:
    return add(trie,0,str,0)

// Add a string into a Trie from a given state, producing an 
// updated Trie.
function add(Trie trie, int state, ascii::string str, int index) -> Trie
requires state >= 0:
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
                // Yes, existing transition for character
                return add(trie,t.to,str,index+1)
            i = i + 1
        // 
        // No existing transition, so make a new one.
        int target = |trie.transitions| + 1
        Transition t = { from: state, to: target, character: c }
        trie.transitions = add(trie.transitions,t)
        return add(trie,target,str,index+1)

// Add a new transition to the trie.  This function should be
// deprecate when it becomes easier to reuse one of the existing Array
// functions.
function add(Transition[] ts, Transition transition) -> Transition[]:
    Transition[] r = [EmptyTransition; |ts|+1]
    // copy over all existing ts
    int i = 0
    while i < |ts|:
        r[i] = ts[i]
        i = i + 1
    // add in the new transition
    r[i] = transition
    // done
    return r

// Check whether a given string is contained in the trie, 
// starting from the root state.
function contains(Trie trie, ascii::string str) -> bool:        
    return contains(trie,0,str,0)

// Check whether a given string is contained in the trie, 
// starting from a given state.
function contains(Trie trie, int state, ascii::string str, int index) -> bool
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
    
method main(ascii::string[] args):
    Trie t = EmptyTrie
    ascii::string[] inputs = ["hello","world","help"]
    // First, initialise trie    
    nat i = 0
    while i < |inputs|:
        io::print("ADDING: ")
        io::println(inputs[i])
        t = add(t,inputs[i])   
        i = i + 1
    // Second, check containment
    ascii::string[] checks = ["hello","blah","hel","dave"]
    i = 0 
    while i < |checks|:
        bool r = contains(t,checks[i])
        io::print("CONTAINS: ")
        io::print(checks[i])
        io::print(" = ")
        if r:
            io::println("true")
        else:
            io::println("false")
        i = i + 1
    
