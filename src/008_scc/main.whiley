import std::array
import std::ascii
import std::math
import Vector,push,pop,top,size from std::collections::vector

type nat is (int x) where x >= 0

// ============================================
// Adjacency List directed graph structure
// ============================================

type Digraph is (nat[][] edges)
    where all { i in 0..|edges|, j in 0..|edges[i]| | edges[i][j] < |edges| }

type Edge is { nat from, nat to }

Digraph EMPTY_DIGRAPH = [[0;0];0]

function addEdge(Digraph g, nat from, nat to) -> Digraph:
    // First, ensure enough capacity
    int max = math::max(from,to)
    g = resize(g,max+1)
    // Second, add the actual edge
    g[from] = array::append(g[from],to)
    // Done
    return g

// Ensure graph has sufficient capacity
function resize(Digraph g, int size) -> (Digraph r)
ensures |r| > size || (size >= |g| && |r| == size):
    //
    if size >= |g|:
        // Graph smaller than required
        Digraph ng = [[0;0]; size]
        nat i = 0
        while i < |g|:
            ng[i] = g[i]
            i = i + 1
        return ng
    else:
        // Graph already big enough
        return g

// ============================================
// Constructors
// ============================================

function Digraph(Edge[] input) -> Digraph:
    //
    Digraph graph = EMPTY_DIGRAPH
    for i in 0..|input|:
        Edge e = input[i]
        graph = addEdge(graph,e.from,e.to)
    //        
    return graph

function Edge(nat from, nat to) -> Edge:
    return {from:from,to:to}

// ============================================
// PEA_FIND_SCC1
// ============================================

// See: "An Improved Algorithm for Finding the Strongly Connected 
// Components of a Directed Graph", Information Processing Letters, 
// David J. Pearce, 2015.

type State is {
    Digraph graph,
    bool[] visited,
    bool[] inComponent,
    int[] rindex,
    Vector<nat> stack,
    int index,
    int cindex
}
where |visited| == |graph|
where |inComponent| == |graph|
where |rindex| == |graph|
// Every vertex on stack must be valid
where all { k in 0..stack.length | stack.items[k] < |graph| }

function State(Digraph g) -> State:
    return {
        graph: g,
        visited: [false; |g|],
        inComponent: [false; |g|],
        rindex: [0; |g|],    
        stack: Vector<nat>(),
        index: 0,
        cindex: 0
    }

function find_components(Digraph g) -> int[][]:
    State state = State(g)
    
    nat i = 0
    while i < |g|:
        if !state.visited[i]:
            state = visit(i,state)
        i = i + 1
    
    // build componnent list
    int[][] components = [[0;0]; state.cindex]
    i = 0 
    //
    while i < |g|:
        int cindex = state.rindex[i]
        components[cindex] = array::append(components[cindex],i)
        i = i + 1
    //
    return components

function visit(nat v, State s) -> State
requires v < |s.graph|:
    bool root = true
    s.visited[v] = true
    s.rindex[v] = s.index
    s.index = s.index + 1
    s.inComponent[v] = false
    // process edges
    int i = 0
    while i < |s.graph[v]|:
        nat w = s.graph[v][i]
        if !s.visited[w]:
            s = visit(w,s)
        if !s.inComponent[w] && s.rindex[w] < s.rindex[v]:
            s.rindex[v] = s.rindex[w]
            root = false
        i = i + 1
    // check to see if we're a component root
    if root:
        s.inComponent[v] = true
        int rindex_v = s.rindex[v]
        while size(s.stack) > 0 && rindex_v <= s.rindex[top(s.stack)]:
            int w = top(s.stack)
            s.stack = pop(s.stack)
            s.rindex[w] = s.cindex
            s.inComponent[w] = true
        s.rindex[v] = s.cindex
        s.cindex = s.cindex + 1
    else:
        s.stack = push(s.stack,v)
    // all done
    return s

// ============================================
// Tests
// ============================================

public method test_01():
    assume find_components(Digraph([Edge(0,1)])) == [[0],[1]]
